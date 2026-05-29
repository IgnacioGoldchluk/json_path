defmodule JSONPath.Eval do
  @moduledoc false

  alias JSONPath.Eval.Slice

  @operators [:eq, :neq, :gt, :gte, :lt, :lte]
  @node_true [true]
  @node_false []

  def evaluate(root, ast), do: evaluate(root, root, ast)

  defp evaluate(root, current_node, conditions) do
    do_eval(root, current_node, conditions) |> discard_nothing()
  end

  defp do_eval(_root, current_node, {:selectors, :current_node, :full}), do: [current_node]
  defp do_eval(root, _current_onde, {:selectors, :root, :full}), do: [root]

  defp do_eval(root, current_node, {:selectors, :current_node, conditions}) do
    Enum.flat_map(conditions, &evaluate_selector(root, current_node, &1)) |> discard_nothing()
  end

  defp do_eval(root, _current_node, {:selectors, :root, conditions}) do
    Enum.flat_map(conditions, &evaluate_selector(root, root, &1)) |> discard_nothing()
  end

  defp do_eval(root, current_node, {:selectors, to_select, conditions}) do
    evaluate(root, current_node, to_select)
    |> Enum.flat_map(&evaluate_selectors(root, &1, conditions))
    |> discard_nothing()
  end

  # For descendant segments:
  # - Nodes in an array are visited in order
  # - Nodes are visited before their descendants
  defp do_eval(root, current_node, {:descendant_segment, selector, conditions}) do
    evaluate(root, current_node, selector)
    |> Enum.flat_map(fn node ->
      node_matching = Enum.flat_map(conditions, &evaluate_selector(root, node, &1))
      child_conditions = {:descendant_segment, {:selectors, :current_node, :full}, conditions}

      children_matching =
        node
        |> iter_values()
        |> Enum.flat_map(&evaluate(root, &1, child_conditions))

      node_matching ++ children_matching
    end)
    |> discard_nothing()
  end

  # Filter expressions
  defp do_eval(_root, _current_node, {:literal, value}), do: [value]

  defp do_eval(root, current_node, {op, left, right}) when op in @operators do
    left_res = evaluate(root, current_node, left)
    right_res = evaluate(root, current_node, right)

    case op do
      :eq -> left_res == right_res
      :neq -> left_res != right_res
      :gt -> type_strict_op(left_res, right_res, &Kernel.>/2)
      :lt -> type_strict_op(left_res, right_res, &Kernel.</2)
      :gte -> left_res == right_res or type_strict_op(left_res, right_res, &Kernel.>/2)
      :lte -> left_res == right_res or type_strict_op(left_res, right_res, &Kernel.</2)
    end
    |> to_node_boolean()
  end

  defp do_eval(root, current_node, {:not, expr}) do
    case evaluate(root, current_node, expr) do
      @node_false -> @node_true
      _ -> @node_false
    end
  end

  defp do_eval(root, current_node, {:and, expr1, expr2}) do
    case evaluate(root, current_node, expr1) do
      @node_false -> @node_false
      _ -> evaluate(root, current_node, expr2) |> discard_nothing()
    end
  end

  defp do_eval(root, current_node, {:or, expr1, expr2}) do
    case evaluate(root, current_node, expr1) do
      @node_false -> evaluate(root, current_node, expr2)
      other -> other
    end
  end

  # Functions
  defp do_eval(root, current_node, {:function, :length, [expr]}) do
    case evaluate(root, current_node, expr) do
      [value] when is_list(value) -> [length(value)]
      [value] when is_map(value) -> [map_size(value)]
      [value] when is_binary(value) -> [String.length(value)]
      _ -> [:nothing]
    end
  end

  defp do_eval(root, current_node, {:function, :value, [expr]}) do
    case evaluate(root, current_node, expr) do
      [value] -> [value]
      _ -> [:nothing]
    end
  end

  defp do_eval(root, current_node, {:function, :count, [expr]}) do
    [length(evaluate(root, current_node, expr))]
  end

  defp do_eval(root, current_node, {:function, :search, [expr1, expr2]}) do
    with [string] when is_binary(string) <- evaluate(root, current_node, expr1),
         [regex] <- evaluate(root, current_node, expr2),
         {:ok, pattern} <- compile_pattern(regex) do
      Regex.match?(pattern, string) |> to_node_boolean()
    else
      _ -> @node_false
    end
  end

  defp do_eval(root, current_node, {:function, :match, [expr1, expr2]}) do
    with [string] when is_binary(string) <- evaluate(root, current_node, expr1),
         [regex] <- evaluate(root, current_node, expr2),
         {:ok, pattern} <- compile_pattern(regex) do
      matches = pattern |> Regex.scan(string, capture: :first) |> Enum.map(fn [val] -> val end)
      to_node_boolean(string in matches)
    else
      _ -> @node_false
    end
  end

  defp evaluate_selectors(root, current_node, conditions) when is_list(conditions) do
    Enum.flat_map(conditions, &evaluate_selector(root, current_node, &1))
  end

  defp evaluate_selector(_root, node, :wildcard) do
    cond do
      is_list(node) -> node
      is_map(node) -> Map.values(node)
      true -> [:nothing]
    end
  end

  defp evaluate_selector(_root, node, {:property, key})
       when is_map(node) and is_map_key(node, key) do
    [node[key]]
  end

  defp evaluate_selector(_root, _node, {:property, _}), do: [:nothing]

  defp evaluate_selector(_root, node, {:index, idx}) when is_list(node) do
    case Enum.at(node, idx) do
      nil -> [:nothing]
      value -> [value]
    end
  end

  defp evaluate_selector(_root, _node, {:index, _}), do: [:nothing]

  defp evaluate_selector(_root, v, {:slice, _, _, step}) when step == 0 or not is_list(v),
    do: [:nothing]

  defp evaluate_selector(_root, [], {:slice, _, _, _}), do: [:nothing]

  defp evaluate_selector(_, node, {:slice, start, stop, step}) when is_list(node) do
    Slice.apply(node, start, stop, step)
  end

  defp evaluate_selector(root, node, {:filter, expr}) when is_map(node) or is_list(node) do
    node |> iter_values() |> Enum.filter(&true_expr?(root, &1, expr))
  end

  defp evaluate_selector(_root, _node, {:filter, _}), do: [:nothing]

  defp iter_values(node) when is_list(node), do: node
  defp iter_values(node) when is_map(node), do: Map.values(node)
  defp iter_values(_node), do: []

  defp true_expr?(root, node, expr), do: not Enum.empty?(evaluate(root, node, expr))

  # Since JSON Path uses arrays to express true/false, we must convert some boolean
  # results (from ==, >, etc.) to an array with equivalent behavior
  defp to_node_boolean(true), do: @node_true
  defp to_node_boolean(false), do: @node_false
  defp to_node_boolean(@node_true), do: @node_true
  defp to_node_boolean(@node_false), do: @node_false

  defp type_strict_op([l], [r], func) when is_binary(l) and is_binary(r), do: func.(l, r)
  defp type_strict_op([l], [r], func) when is_number(l) and is_number(r), do: func.(l, r)
  defp type_strict_op(_, _, _), do: false

  defp discard_nothing(results), do: Enum.reject(results, &(&1 == :nothing))

  defp compile_pattern(%Regex{} = pattern), do: {:ok, pattern}
  defp compile_pattern(pattern) when is_binary(pattern), do: Regex.compile(pattern, "u")
  defp compile_pattern(_), do: [:nothing]
end
