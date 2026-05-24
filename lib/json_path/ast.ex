defmodule JSONPath.AST do
  @moduledoc """
  AST parsing and representation of a JSONPath query expression
  """

  @opaque t() :: tuple()

  @comparison_operators [:lt, :lte, :eq, :gte, :gt, :neq]
  def parse(tokens) do
    {ast, []} = parse_path(tokens)
    validate(ast)
  catch
    {:error, _} = error -> error
  end

  defp parse_path([node | tokens]) when node in [:root, :current_node] do
    parse_path_segments({:selectors, node, :full}, tokens)
  end

  defp parse_path_segments({:selectors, node, :full}, [:lbracket | tokens]) do
    {selectors, remaining} = parse_selectors(tokens)
    parse_path_segments({:selectors, node, selectors}, remaining)
  end

  defp parse_path_segments(path, [:lbracket | tokens]) do
    {selectors, remaining} = parse_selectors(tokens)
    parse_path_segments({:selectors, path, selectors}, remaining)
  end

  defp parse_path_segments(path, [:descendant_segment, :lbracket | tokens]) do
    {selectors, remaining} = parse_selectors(tokens)
    parse_path_segments({:descendant_segment, path, selectors}, remaining)
  end

  defp parse_path_segments(path, tokens), do: {path, tokens}

  defp parse_selectors(tokens), do: parse_selectors(tokens, [])

  defp parse_selectors(tokens, selectors) do
    {selector, [separator | remaining_tokens]} = parse_selector(tokens)

    case separator do
      :comma -> parse_selectors(remaining_tokens, [selector | selectors])
      :rbracket -> {Enum.reverse([selector | selectors]), remaining_tokens}
    end
  end

  defp parse_selector([:filter | tokens]) do
    {filter, remaining} = parse_expression(tokens)
    {{:filter, filter}, remaining}
  end

  defp parse_selector([{:slice, _, _, _} = selector | remaining]), do: {selector, remaining}
  defp parse_selector([{:index, _idx} = selector | remaining]), do: {selector, remaining}
  defp parse_selector([{:property, _name} = selector | remaining]), do: {selector, remaining}
  defp parse_selector([:wildcard | remaining]), do: {:wildcard, remaining}

  defp parse_selector(ast) do
    throw({:error, %JSONPath.Error{type: :invalid_expression, expression: ast_to_string(ast)}})
  end

  defp parse_expression(tokens), do: parse_or(tokens)

  defp parse_or(tokens) do
    {left, remaining} = parse_and(tokens)
    parse_binary_operator(left, remaining, [:or], &parse_and/1)
  end

  defp parse_and(tokens) do
    {left, remaining} = parse_comparison(tokens)
    parse_binary_operator(left, remaining, [:and], &parse_comparison/1)
  end

  defp parse_comparison(tokens) do
    {left, remaining} = parse_unary(tokens)
    parse_binary_operator(left, remaining, @comparison_operators, &parse_unary/1)
  end

  defp parse_unary([:not | tokens]) do
    {expr, remaining} = parse_unary(tokens)
    {{:not, expr}, remaining}
  end

  defp parse_unary(tokens), do: parse_primary(tokens)

  defp parse_binary_operator(left, [operator | tokens] = remaining, operators, next_parser) do
    if operator in operators do
      {right, remaining} = next_parser.(tokens)
      parse_binary_operator({operator, left, right}, remaining, operators, next_parser)
    else
      {left, remaining}
    end
  end

  # This might be unreachable
  defp parse_binary_operator(left, remaining, _operators, _next_parser), do: {left, remaining}

  defp parse_primary([{:literal, _value} = literal | remaining]) do
    {literal, remaining}
  end

  defp parse_primary([node | _tokens] = tokens) when node in [:root, :current_node] do
    parse_path(tokens)
  end

  defp parse_primary([{:function, function}, :lparen | tokens]) do
    {arguments, remaining} = parse_function_arguments(tokens)
    {{:function, function, arguments}, remaining}
  end

  defp parse_primary([:lparen | tokens]) do
    {expr, [:rparen | remaining_tokens]} = parse_expression(tokens)
    {expr, remaining_tokens}
  end

  # This might be unreachable
  defp parse_function_arguments([:rparen | remaining]), do: {[], remaining}

  defp parse_function_arguments(tokens), do: parse_function_arguments(tokens, [])

  defp parse_function_arguments(tokens, arguments) do
    {argument, [separator | remaining_tokens]} = parse_expression(tokens)

    case separator do
      :comma -> parse_function_arguments(remaining_tokens, [argument | arguments])
      :rparen -> {Enum.reverse([argument | arguments]), remaining_tokens}
    end
  end

  defp validate(parsed_ast) do
    validations = [
      &single_value_query_comparisons/1,
      &comparison_filters/1,
      &safe_index/1,
      &function_arity/1,
      &function_comparison/1,
      &count_takes_query/1,
      &length_single_query/1,
      &no_regex_comparison/1
    ]

    Enum.reduce_while(validations, :ok, fn validation_func, :ok ->
      case validation(parsed_ast, validation_func) do
        :ok -> {:cont, :ok}
        {:error, _} = error -> {:halt, error}
      end
    end)
    |> case do
      :ok -> {:ok, parsed_ast}
      {:error, _} = error -> error
    end
  end

  defp validation(ast, func) when is_list(ast) do
    Enum.reduce_while(ast, :ok, fn node, :ok ->
      case validation(node, func) do
        :ok -> {:cont, :ok}
        {:error, _} = error -> {:halt, error}
      end
    end)
  end

  defp validation(ast, func) when is_tuple(ast) do
    case func.(ast) do
      :ok -> validation(Tuple.to_list(ast), func)
      {:error, _} = e -> e
    end
  end

  defp validation(_ast, _func), do: :ok

  defp no_regex_comparison({op, expr1, expr2} = node) when op in @comparison_operators do
    if regex_function?(expr1) or regex_function?(expr2) do
      {:error,
       %JSONPath.Error{
         type: :unexpected_comparison,
         expression: ast_to_string(node),
         message: "function cannot be compared"
       }}
    else
      :ok
    end
  end

  defp no_regex_comparison(_), do: :ok

  defp regex_function?({:function, :match, _}), do: true
  defp regex_function?({:function, :search, _}), do: true
  defp regex_function?(_), do: false

  defp length_single_query({:function, :length, [arg]}) do
    if single_value_query?(arg) do
      :ok
    else
      {:error,
       %JSONPath.Error{
         type: :unexpected_argument,
         expression: ast_to_string(arg),
         message: "length function takes single-query argument"
       }}
    end
  end

  defp length_single_query(_), do: :ok

  defp count_takes_query({:function, :count, [{:selectors, _, _}]}), do: :ok
  defp count_takes_query({:function, :count, [{:descendant_segment, _, _}]}), do: :ok

  defp count_takes_query({:function, :count, [arg]}) do
    {:error,
     %JSONPath.Error{
       type: :unexpected_argument,
       expression: ast_to_string(arg),
       message: "count function requires query or selector as argument"
     }}
  end

  defp count_takes_query(_), do: :ok

  defp function_comparison({:filter, {:function, name, _args} = node})
       when name in [:length, :count, :value] do
    {:error,
     %JSONPath.Error{
       type: :invalid_expression,
       expression: ast_to_string(node),
       message: "comparison operator expected"
     }}
  end

  defp function_comparison({op, expr1, expr2} = node) when op in [:and, :or] do
    if comparable_function?(expr1) or comparable_function?(expr2) do
      {:error,
       %JSONPath.Error{
         type: :invalid_expression,
         expression: ast_to_string(node),
         message: "comparison operator expected"
       }}
    else
      :ok
    end
  end

  defp function_comparison(_), do: :ok

  defp comparable_function?({:function, name, _}), do: name in [:length, :count, :value]
  defp comparable_function?(_), do: false

  defp function_arity({:function, name, args} = node) do
    got = length(args)
    expected = args(name)

    if got == expected do
      :ok
    else
      {:error,
       %JSONPath.Error{
         type: :invalid_expression,
         expression: ast_to_string(node),
         message: "got #{got} arguments but function #{name} expects #{expected} arguments"
       }}
    end
  end

  defp function_arity(_), do: :ok

  defp args(:match), do: 2
  defp args(:search), do: 2
  defp args(:count), do: 1
  defp args(:length), do: 1
  defp args(:value), do: 1

  defp safe_index({:index, val}) do
    if val >= -(2 ** 53 - 1) and val <= 2 ** 53 - 1 do
      :ok
    else
      {:error,
       %JSONPath.Error{
         type: :invalid_number,
         expression: to_string(val),
         message: "index must be between +- (2**53) - 1"
       }}
    end
  end

  defp safe_index(_), do: :ok

  defp comparison_filters({:filter, {:literal, _}} = node) do
    {:error,
     %JSONPath.Error{
       type: :invalid_expression,
       expression: ast_to_string(node),
       message: "value in filter must be used in comparison expression"
     }}
  end

  defp comparison_filters({:not, {:literal, _}} = node) do
    {:error,
     %JSONPath.Error{
       type: :invalid_expression,
       expression: ast_to_string(node),
       message: "value in filter must be used in comparison expression"
     }}
  end

  defp comparison_filters({op, expr1, expr2} = node) when op in [:and, :or] do
    if match?({:literal, _}, expr1) or match?({:literal, _}, expr2) do
      {:error,
       %JSONPath.Error{
         type: :invalid_expression,
         expression: ast_to_string(node),
         message: "value in filter must be used in comparison expression"
       }}
    else
      :ok
    end
  end

  defp comparison_filters(_), do: :ok

  defp single_value_query_comparisons({op, expr1, expr2} = node)
       when op in @comparison_operators do
    if single_value_query?(expr1) and single_value_query?(expr2) do
      :ok
    else
      {:error,
       %JSONPath.Error{
         type: :invalid_expression,
         expression: ast_to_string(node),
         message: "comparison operator requires single value queries"
       }}
    end
  end

  defp single_value_query_comparisons(_), do: :ok

  defp single_value_query?({:selectors, _, :full}), do: true
  defp single_value_query?({:selectors, _, values}) when length(values) > 1, do: false
  defp single_value_query?({:selectors, _, [{:slice, _start, _stop, _step}]}), do: false
  defp single_value_query?({:selectors, _, [{:filter, _}]}), do: false
  defp single_value_query?({:selectors, _, [:wildcard]}), do: false
  defp single_value_query?({:descendant_segment, _, _}), do: false
  defp single_value_query?({:selectors, selector, _}), do: single_value_query?(selector)
  defp single_value_query?(_), do: true

  defp ast_to_string(:root), do: "$"
  defp ast_to_string(:current_node), do: "@"

  defp ast_to_string({:selectors, node, :full}), do: ast_to_string(node)

  defp ast_to_string({:selectors, node, selectors}) do
    "#{ast_to_string(node)}[#{Enum.map_join(selectors, ", ", &ast_to_string/1)}]"
  end

  defp ast_to_string({:descendant_segment, node, selectors}) do
    "#{ast_to_string(node)}..[#{Enum.map_join(selectors, ", ", &ast_to_string/1)}]"
  end

  defp ast_to_string({:and, l, r}), do: ast_to_string(l) <> " && " <> ast_to_string(r)
  defp ast_to_string({:or, l, r}), do: ast_to_string(l) <> " || " <> ast_to_string(r)
  defp ast_to_string({:not, expr}), do: "!(#{ast_to_string(expr)})"

  defp ast_to_string({op, l, r}) when op in @comparison_operators do
    "#{ast_to_string(l)} #{comp(op)} #{ast_to_string(r)}"
  end

  defp ast_to_string({:index, val}), do: to_string(val)
  defp ast_to_string({:property, name}), do: "'#{name}'"
  defp ast_to_string({:literal, s}) when is_binary(s), do: "'#{s}'"
  defp ast_to_string({:literal, nil}), do: "null"
  defp ast_to_string({:literal, val}), do: to_string(val)
  defp ast_to_string({:filter, clause}), do: "?(#{ast_to_string(clause)})"
  defp ast_to_string(:wildcard), do: "*"

  defp ast_to_string({:slice, start, stop, step}) do
    "#{to_string(start)}:#{to_string(stop)}:#{to_string(step)}"
  end

  defp ast_to_string({:function, name, args}) do
    "#{name}(#{Enum.map_join(args, ", ", &ast_to_string/1)})"
  end

  # Invalid expression
  defp ast_to_string(node) when is_list(node), do: ""

  defp comp(:lt), do: "<"
  defp comp(:lte), do: "<="
  defp comp(:gt), do: ">"
  defp comp(:gte), do: ">="
  defp comp(:eq), do: "=="
  defp comp(:neq), do: "!="
end
