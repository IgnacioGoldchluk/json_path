defmodule JSONPath.Eval do
  @moduledoc false

  alias JSONPath.Eval.Slice

  @operators [:eq, :neq, :gt, :gte, :lt, :lte]
  @node_false []

  @type path :: [String.t() | non_neg_integer()]
  @type jsonpath_node :: {any(), path()}

  def evaluate(root, ast), do: evaluate(root, root, ast, [])

  @spec evaluate(any(), any(), any(), path()) :: jsonpath_node()
  defp evaluate(root, current_node, conditions, path) do
    do_eval(root, current_node, conditions, path) |> discard_nothing()
  end

  defp do_eval(_root, current_node, {:selectors, :current_node, :full}, path) do
    [{current_node, path}]
  end

  defp do_eval(root, _current_node, {:selectors, :root, :full}, _) do
    [{root, []}]
  end

  defp do_eval(root, current_node, {:selectors, :current_node, conditions}, path) do
    conditions
    |> Enum.flat_map(&evaluate_selector(root, current_node, &1, path))
    |> discard_nothing()
  end

  defp do_eval(root, _current_node, {:selectors, :root, conditions}, path) do
    conditions
    |> Enum.flat_map(&evaluate_selector(root, root, &1, path))
    |> discard_nothing()
  end

  defp do_eval(root, current_node, {:selectors, to_select, conditions}, path) do
    evaluate(root, current_node, to_select, path)
    |> Enum.flat_map(fn {node, path} -> evaluate_selectors(root, node, conditions, path) end)
    |> discard_nothing()
  end

  # For descendant segments:
  # - Nodes in an array are visited in order
  # - Nodes are visited before their descendants
  defp do_eval(root, current_node, {:descendant_segment, selector, conditions}, path) do
    evaluate(root, current_node, selector, path)
    |> Enum.flat_map(fn {node, path} ->
      node_matching = Enum.flat_map(conditions, &evaluate_selector(root, node, &1, path))

      child_conditions = {:descendant_segment, {:selectors, :current_node, :full}, conditions}

      children_matching =
        node
        |> iter()
        |> Enum.flat_map(fn {value, key_or_idx} ->
          evaluate(root, value, child_conditions, [key_or_idx | path])
        end)

      node_matching ++ children_matching
    end)
    |> discard_nothing()
  end

  # Filter expressions
  defp do_eval(_root, _current_node, {:literal, value}, path), do: [{value, path}]

  defp do_eval(root, current_node, {op, left, right}, path) when op in @operators do
    left_res = evaluate(root, current_node, left, path) |> value()
    right_res = evaluate(root, current_node, right, path) |> value()

    case op do
      :eq -> left_res == right_res
      :neq -> left_res != right_res
      :gt -> type_strict_op(left_res, right_res, &Kernel.>/2)
      :lt -> type_strict_op(left_res, right_res, &Kernel.</2)
      :gte -> left_res == right_res or type_strict_op(left_res, right_res, &Kernel.>/2)
      :lte -> left_res == right_res or type_strict_op(left_res, right_res, &Kernel.</2)
    end
    |> to_node_boolean(path)
  end

  defp do_eval(root, current_node, {:not, expr}, path) do
    case evaluate(root, current_node, expr, path) do
      @node_false -> [{true, path}]
      _ -> @node_false
    end
  end

  defp do_eval(root, current_node, {:and, expr1, expr2}, path) do
    case evaluate(root, current_node, expr1, path) do
      @node_false -> @node_false
      _ -> evaluate(root, current_node, expr2, path) |> discard_nothing()
    end
  end

  defp do_eval(root, current_node, {:or, expr1, expr2}, path) do
    case evaluate(root, current_node, expr1, path) do
      @node_false -> evaluate(root, current_node, expr2, path)
      other -> other
    end
  end

  # Functions
  defp do_eval(root, current_node, {:function, :length, [expr]}, path) do
    case evaluate(root, current_node, expr, path) |> value() do
      [value] when is_list(value) -> [{length(value), path}]
      [value] when is_map(value) -> [{map_size(value), path}]
      [value] when is_binary(value) -> [{String.length(value), path}]
      _ -> [{:nothing, path}]
    end
  end

  defp do_eval(root, current_node, {:function, :value, [expr]}, path) do
    case evaluate(root, current_node, expr, path) do
      [{value, _}] -> [{value, path}]
      _ -> [{:nothing, path}]
    end
  end

  defp do_eval(root, current_node, {:function, :count, [expr]}, path) do
    [{length(evaluate(root, current_node, expr, path)), path}]
  end

  defp do_eval(root, current_node, {:function, :search, [expr1, expr2]}, path) do
    with [string] when is_binary(string) <- evaluate(root, current_node, expr1, path) |> value(),
         [regex] <- evaluate(root, current_node, expr2, path) |> value(),
         {:ok, pattern} <- compile_pattern(regex) do
      Regex.match?(pattern, string) |> to_node_boolean(path)
    else
      _ -> @node_false
    end
  end

  defp do_eval(root, current_node, {:function, :match, [expr1, expr2]}, path) do
    with [string] when is_binary(string) <- evaluate(root, current_node, expr1, path) |> value(),
         [regex] <- evaluate(root, current_node, expr2, path) |> value(),
         {:ok, pattern} <- compile_pattern(regex) do
      matches = pattern |> Regex.scan(string, capture: :first) |> Enum.map(fn [val] -> val end)
      to_node_boolean(string in matches, path)
    else
      _ -> @node_false
    end
  end

  defp evaluate_selectors(root, current_node, conditions, path) when is_list(conditions) do
    Enum.flat_map(conditions, &evaluate_selector(root, current_node, &1, path))
  end

  defp evaluate_selector(_root, node, :wildcard, path) do
    cond do
      is_list(node) ->
        node
        |> Enum.with_index()
        |> Enum.map(fn {val, idx} -> {val, [idx | path]} end)

      is_map(node) ->
        Enum.map(node, fn {k, v} -> {v, [k | path]} end)

      true ->
        [{:nothing, path}]
    end
  end

  defp evaluate_selector(_root, node, {:property, key}, path)
       when is_map(node) and is_map_key(node, key) do
    [{node[key], [key | path]}]
  end

  defp evaluate_selector(_root, _node, {:property, _}, path), do: [{:nothing, path}]

  defp evaluate_selector(_root, node, {:index, idx}, path) when is_list(node) do
    case Enum.at(node, idx) do
      nil -> [{:nothing, path}]
      value -> [{value, [to_positive(idx, length(node)) | path]}]
    end
  end

  defp evaluate_selector(_root, _node, {:index, _}, path), do: [{:nothing, path}]

  defp evaluate_selector(_root, v, {:slice, _, _, step}, path) when step == 0 or not is_list(v),
    do: [{:nothing, path}]

  defp evaluate_selector(_root, [], {:slice, _, _, _}, path), do: [{:nothing, path}]

  defp evaluate_selector(_, node, {:slice, start, stop, step}, path) when is_list(node) do
    Enum.map(Slice.apply(node, start, stop, step), fn {value, index} ->
      {value, [index | path]}
    end)
  end

  defp evaluate_selector(root, node, {:filter, expr}, path) when is_map(node) or is_list(node) do
    node
    |> iter()
    |> Enum.filter(fn {node, key_or_idx} ->
      true_expr?(root, node, expr, [key_or_idx | path])
    end)
    |> Enum.map(fn {node, key_or_idx} -> {node, [key_or_idx | path]} end)
  end

  defp evaluate_selector(_root, _node, {:filter, _}, path), do: [{:nothing, path}]

  defp iter(node) when is_list(node), do: Enum.with_index(node)
  defp iter(node) when is_map(node), do: Enum.map(node, fn {k, v} -> {v, k} end)
  defp iter(_node), do: []

  defp true_expr?(root, node, expr, path), do: not Enum.empty?(evaluate(root, node, expr, path))

  # Since JSON Path uses arrays to express true/false, we must convert some boolean
  # results (from ==, >, etc.) to an array with equivalent behavior
  defp to_node_boolean(true, path), do: [{true, path}]
  defp to_node_boolean(false, _path), do: []
  defp to_node_boolean([true], path), do: [{true, path}]
  defp to_node_boolean([], _path), do: []

  defp type_strict_op([l], [r], func) when is_binary(l) and is_binary(r), do: func.(l, r)
  defp type_strict_op([l], [r], func) when is_number(l) and is_number(r), do: func.(l, r)
  defp type_strict_op(_, _, _), do: false

  @spec discard_nothing(list(node)) :: list(node)
  defp discard_nothing(results), do: Enum.reject(results, &(elem(&1, 0) == :nothing))

  defp compile_pattern(%Regex{} = pattern), do: {:ok, pattern}
  defp compile_pattern(pattern) when is_binary(pattern), do: Regex.compile(pattern, "u")
  defp compile_pattern(_), do: [:nothing]

  defp value([]), do: []
  defp value([{val, _path}]), do: [val]
  defp value(vals) when is_list(vals), do: Enum.map(vals, &value/1)

  defp to_positive(index, _len) when index >= 0, do: index
  defp to_positive(index, len), do: len + index
end
