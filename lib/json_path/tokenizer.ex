defmodule JSONPath.Tokenizer do
  @moduledoc false

  import Bitwise

  @selector_separators [?,, ?]]
  @number_codepoints [?e, ?E, ?., ?-, ?+] ++ Enum.to_list(?0..?9)
  @slice_codepoints [?-, ?:] ++ Enum.to_list(?0..?9)

  defguardp is_quote(q) when q in [?', ?"]
  defguardp is_whitespace(s) when s in [?\s, ?\r, ?\n, ?\t, ?\f, ?\v]
  defguardp is_control_codepoint(s) when s in 0x000..0x001F

  @type operand() :: :lt | :lte | :eq | :gte | :gt | :neq | :and | :or
  @type function_extension() :: :length | :count | :match | :search | :value

  @type selector() ::
          {:index, integer()}
          | :filter
          | {:slice, start :: integer() | nil, stop :: integer() | nil, step :: integer() | nil}
          | {:property, String.t()}
          | :wildcard
          | :descendant_segment

  @type token() ::
          :root
          | :current_node
          # Thankfully literal arrays and literal objects are not supported for comparison
          | {:literal, nil | true | false | number() | String.t()}
          | operand()
          | :lparen
          | :rparen
          | :lbracket
          | :rbracket
          | :comma
          | selector()

  defp to_codepoints(str) when is_binary(str) do
    for <<c::utf8 <- str>>, do: c
  end

  def tokenize(input) when is_binary(input) do
    tokenize(to_codepoints(input), [])
  catch
    {:error, _reason} = e -> e
  end

  defp tokenize([s], _) when is_whitespace(s) do
    {:error, %JSONPath.Error{type: :invalid_expression, message: "trailing whitespace found"}}
  end

  defp tokenize([x | _], []) when x != ?$ do
    {:error, %JSONPath.Error{type: :invalid_expression, message: "must start with '$"}}
  end

  defp tokenize([], acc), do: {:ok, Enum.reverse(acc)}

  # Ignore spaces
  defp tokenize([s | rest], acc) when is_whitespace(s), do: tokenize(rest, acc)
  # Special symbols
  defp tokenize([?$ | rest], acc), do: tokenize(rest, [:root | acc])
  defp tokenize([?@ | rest], acc), do: tokenize(rest, [:current_node | acc])
  defp tokenize([?* | rest], acc), do: tokenize(rest, [:wildcard | acc])
  defp tokenize([?? | rest], acc), do: tokenize(rest, [:filter | acc])
  # Opening and closing delimiters
  defp tokenize([?[ | rest], acc), do: tokenize(rest, [:lbracket | acc])
  defp tokenize([?] | rest], acc), do: tokenize(rest, [:rbracket | acc])
  defp tokenize([?( | rest], acc), do: tokenize(rest, [:lparen | acc])
  defp tokenize([?) | rest], acc), do: tokenize(rest, [:rparen | acc])
  defp tokenize([?, | rest], acc), do: tokenize(rest, [:comma | acc])
  # Comparisons
  defp tokenize([?=, ?= | rest], acc), do: tokenize(rest, [:eq | acc])
  defp tokenize([?!, ?= | rest], acc), do: tokenize(rest, [:neq | acc])
  defp tokenize([?>, ?= | rest], acc), do: tokenize(rest, [:gte | acc])
  defp tokenize([?<, ?= | rest], acc), do: tokenize(rest, [:lte | acc])
  defp tokenize([?> | rest], acc), do: tokenize(rest, [:gt | acc])
  defp tokenize([?< | rest], acc), do: tokenize(rest, [:lt | acc])
  # Boolean operators. Short circuit behaviour is unspecified
  defp tokenize([?&, ?& | rest], acc), do: tokenize(rest, [:and | acc])
  defp tokenize([?|, ?| | rest], acc), do: tokenize(rest, [:or | acc])
  defp tokenize([?! | rest], acc), do: tokenize(rest, [:not | acc])

  ## Child selectors
  # Quoted property
  defp tokenize([q | rest], acc) when is_quote(q) do
    type = if(selector?(acc), do: :property, else: :literal)
    {name, rest} = quoted_value(rest, q)
    tokenize(rest, [{type, name} | acc])
  end

  # Index or slice
  defp tokenize([n | _] = codepoints, acc) when n in @slice_codepoints do
    as_str = to_string(codepoints)

    cond do
      not selector?(acc) ->
        {value, rest} = extract_number(codepoints)
        tokenize(rest, [{:literal, value} | acc])

      Regex.match?(~r/^\s*-?\d+\s*[,\]]/, as_str) ->
        # Single index
        {index, rest} = extract_index(codepoints)
        tokenize(rest, [index | acc])

      true ->
        {slice, rest} = extract_slice(codepoints)
        tokenize(rest, [slice | acc])
    end
  end

  ## Literals
  # true, false, nil
  defp tokenize([?t, ?r, ?u, ?e | rest], acc), do: tokenize(rest, [{:literal, true} | acc])
  defp tokenize([?f, ?a, ?l, ?s, ?e | rest], acc), do: tokenize(rest, [{:literal, false} | acc])
  defp tokenize([?n, ?u, ?l, ?l | rest], acc), do: tokenize(rest, [{:literal, nil} | acc])

  # Descendant segment
  defp tokenize([?., ?.], _acc) do
    {:error, %JSONPath.Error{type: :invalid_expression, message: "empty descendant segment"}}
  end

  defp tokenize([?., ?. | rest], acc) do
    case hd(rest) do
      ?[ ->
        tokenize(rest, [:descendant_segment | acc])

      ?* ->
        tokenize(tl(rest), [:rbracket, :wildcard, :lbracket, :descendant_segment | acc])

      d when d in ?0..?9 ->
        {:error,
         %JSONPath.Error{
           type: :invalid_expression,
           message: "shorthand notation cannot start with digit"
         }}

      _ ->
        {name, rest} = shorthand_property(rest)

        tokenize(rest, [
          :rbracket,
          {:property, to_string(name)},
          :lbracket,
          :descendant_segment | acc
        ])
    end
  end

  # Shorthand property access
  defp tokenize([?., ?* | rest], acc) do
    tokenize(rest, [:rbracket, :wildcard, :lbracket | acc])
  end

  defp tokenize([?., d | _], _) when d in ?0..?9 do
    {:error,
     %JSONPath.Error{
       type: :invalid_expression,
       message: "shorthand notation cannot start with digit"
     }}
  end

  defp tokenize([?. | rest], acc) do
    {name, rest} = shorthand_property(rest)
    tokenize(rest, [:rbracket, {:property, to_string(name)}, :lbracket | acc])
  end

  # Functions
  defp tokenize([?m, ?a, ?t, ?c, ?h, ?( | rest], acc),
    do: tokenize(rest, [:lparen, {:function, :match} | acc])

  defp tokenize([?c, ?o, ?u, ?n, ?t, ?( | rest], acc),
    do: tokenize(rest, [:lparen, {:function, :count} | acc])

  defp tokenize([?v, ?a, ?l, ?u, ?e, ?( | rest], acc),
    do: tokenize(rest, [:lparen, {:function, :value} | acc])

  defp tokenize([?s, ?e, ?a, ?r, ?c, ?h, ?( | rest], acc),
    do: tokenize(rest, [:lparen, {:function, :search} | acc])

  defp tokenize([?l, ?e, ?n, ?g, ?t, ?h, ?( | rest], acc),
    do: tokenize(rest, [:lparen, {:function, :length} | acc])

  defp tokenize(rest, _acc) do
    {:error,
     %JSONPath.Error{
       type: :invalid_expression,
       message: "unexpected sequence: #{to_string(rest)}"
     }}
  end

  defp shorthand_property(codepoints), do: Enum.split_while(codepoints, &shorthand_allowed?/1)

  defp shorthand_allowed?(codepoint) do
    codepoint == ?_ or codepoint in ?a..?z or codepoint in ?A..?Z or codepoint in ?0..?9 or
      codepoint in 128..55_295 or codepoint in 57_344..1_114_111
  end

  # Given a string that started with ' or " in a selector, we have to construct the
  # property name
  defp quoted_value(codepoints, q), do: quoted_value(codepoints, q, [])
  defp quoted_value([?\\, q | rest], q, acc), do: quoted_value(rest, q, [q | acc])

  # Surrogate pairs
  defp quoted_value([?\\, ?u, h1, h2, h3, h4, ?\\, ?u, l1, l2, l3, l4 | rest], q, acc) do
    high_str = [h1, h2, h3, h4] |> to_string()
    low_str = [l1, l2, l3, l4] |> to_string()

    with {:high, {high, ""}} when high in 0xD800..0xDBFF <- {:high, Integer.parse(high_str, 16)},
         {:low, {low, ""}} when low in 0xDC00..0xDFFF <- {:low, Integer.parse(low_str, 16)} do
      # 2**16 + (high - 0xD800)2**10 + (low - 0xDC00)
      codepoint = ((high - 0xD800) <<< 10) + (1 <<< 16) + (low - 0xDC00)
      quoted_value(rest, q, [codepoint | acc])
    else
      {:high, {_, ""}} ->
        # We know this passes. It was a regular unicode instead of surrogate
        {high, ""} = Integer.parse(high_str, 16)
        low = [?\\, ?u, l1, l2, l3, l4]
        quoted_value(low ++ rest, q, [high | acc])

      {:low, _} ->
        throw(
          {:error,
           %JSONPath.Error{
             type: :invalid_unicode,
             expression: "\\u#{high_str}, \\u#{low_str}",
             message: "invalid surrogate pa"
           }}
        )
    end
  end

  # Single unicode point
  defp quoted_value([?\\, ?u, b1, b2, b3, b4 | rest], q, acc) do
    if b1 in [?+, ?{] do
      throw(
        {:error,
         %JSONPath.Error{
           type: :invalid_unicode,
           expression: to_string([?\\, ?u, b1, b2, b3, b4]),
           message: "unnecessary '+' and/or '{' in unicode codepoint"
         }}
      )
    end

    as_str = [b1, b2, b3, b4] |> to_string()

    case Integer.parse(as_str, 16) do
      {codepoint, ""} when codepoint not in 0xD800..0xDFFF ->
        quoted_value(rest, q, [codepoint | acc])

      {codepoint, ""} ->
        throw(
          {:error,
           %JSONPath.Error{
             type: :invalid_unicode,
             expression: codepoint,
             message: "invalid unicode codepoint"
           }}
        )

      _ ->
        throw(
          {:error,
           %JSONPath.Error{
             type: :invalid_unicode,
             expression: as_str,
             message: "invalid unicode format. Must be \\uXXXX"
           }}
        )
    end
  end

  defp quoted_value([?\\, char | rest], q, acc),
    do: quoted_value(rest, q, [to_escaped_codepoint(char) | acc])

  defp quoted_value([q | rest], q, acc), do: {Enum.reverse(acc) |> to_string(), rest}

  defp quoted_value([char | _], _q, _) when is_control_codepoint(char) do
    throw(
      {:error,
       %JSONPath.Error{type: :invalid_unicode, expression: <<char>>, message: "must be escaped"}}
    )
  end

  defp quoted_value([char | rest], q, acc), do: quoted_value(rest, q, [char | acc])

  defp quoted_value(_, _, _) do
    throw({:error, %JSONPath.Error{type: :invalid_expression, message: "missing closing quote"}})
  end

  defp extract_index(codepoints) do
    {index, rest} = Enum.split_while(codepoints, &(&1 not in @selector_separators))

    case safe_integer(to_string(index) |> String.trim()) do
      {:ok, index} -> {{:index, index}, rest}
      {:error, _} = e -> throw(e)
    end
  end

  defp extract_slice(codepoints) do
    {slice, rest} = Enum.split_while(codepoints, &(&1 not in @selector_separators))

    case slice |> to_string() |> String.split(":") do
      [start, end_ | _] = slices when length(slices) in [2, 3] ->
        step = Enum.at(slices, 2, "1")

        with {:no_plus_sign, false} <- {:no_plus_sign, plus_sign?([start, end_, step])},
             {:ok, start} <- to_slice_value(String.trim(start)),
             {:ok, end_} <- to_slice_value(String.trim(end_)),
             {:ok, step} <- to_slice_value(String.trim(step)) do
          {{:slice, start, end_, step || 1}, rest}
        else
          {:no_plus_sign, true} ->
            throw(
              {:error,
               %JSONPath.Error{
                 type: :invalid_number,
                 message: "unnecessary '+' in index/slice",
                 expression: to_string(slice)
               }}
            )

          {:error, _} = e ->
            throw(e)
        end

      _ ->
        throw(
          {:error,
           %JSONPath.Error{
             type: :invalid_expression,
             expression: to_string(slice),
             message: "invalid slice format"
           }}
        )
    end
  end

  defp plus_sign?(numbers) do
    Enum.any?(numbers, fn number -> number != "" and String.starts_with?(number, "+") end)
  end

  defp to_slice_value(""), do: {:ok, nil}
  defp to_slice_value(num) when is_binary(num), do: safe_integer(num)

  # Termination clauses
  # - :lparen before :rparen then we're in a function
  # - :filter with :comma_seen then we're inside selector, pattern was [?..., {HERE}], otherwise
  # we are in a filter
  # - :lbracket we're in selector
  defp selector?(reversed_tokens), do: selector?(reversed_tokens, [], false)
  defp selector?([:lparen | _], [], _comma_seen?), do: false
  defp selector?([:lbracket | _], [], _comma_seen?), do: true
  defp selector?([:filter | _], [], comma_seen?), do: comma_seen?
  defp selector?([:comma | reversed_tokens], [], _), do: selector?(reversed_tokens, [], true)
  # Ignore nested brackets/parens
  defp selector?([:lparen | reversed_tokens], [:rparen | stack], comma_seen?) do
    selector?(reversed_tokens, stack, comma_seen?)
  end

  defp selector?([:lbracket | reversed_tokens], [:rbracket | stack], comma_seen?) do
    selector?(reversed_tokens, stack, comma_seen?)
  end

  defp selector?([:rparen | reversed_tokens], stack, comma_seen?) do
    selector?(reversed_tokens, [:rparen | stack], comma_seen?)
  end

  defp selector?([:rbracket | reversed_tokens], stack, comma_seen?) do
    selector?(reversed_tokens, [:rbracket | stack], comma_seen?)
  end

  defp selector?([_token | rest], stack, comma_seen?) do
    selector?(rest, stack, comma_seen?)
  end

  defp extract_number(codepoints) do
    {number, rest} = Enum.split_while(codepoints, &(&1 in @number_codepoints))
    number_as_str = to_string(number) |> String.trim()

    with {:json_compliant, true} <- {:json_compliant, json_compliant_number?(number_as_str)},
         {int_val, ""} <- Integer.parse(number_as_str),
         {:safe_index, true} <- {:safe_index, safe_index?(int_val)} do
      {int_val, rest}
    else
      {:json_compliant, false} ->
        throw(
          {:error,
           %JSONPath.Error{
             type: :invalid_number,
             expression: number,
             message: "number is not JSON-compliant"
           }}
        )

      {:safe_index, false} ->
        throw(
          {:error,
           %JSONPath.Error{
             type: :invalid_number,
             expression: number_as_str,
             message: "invalid integer"
           }}
        )

      _ ->
        case Float.parse(number_as_str) do
          {floating_point, ""} ->
            {floating_point, rest}

          _ ->
            throw({:error, %JSONPath.Error{type: :invalid_number, expression: number_as_str}})
        end
    end
  end

  defp json_compliant_number?("-0"), do: true

  defp json_compliant_number?(number) when is_binary(number) do
    # Cannot have leading 0s, unless the integer part is 0
    # Cannot end in "."
    # These things are allowed by Elixir but are not JSON compliant
    no_sign =
      case number do
        "+" <> num -> num
        "-" <> num -> num
        _ -> number
      end

    [integer_part | _] = String.split(no_sign, ".")

    if String.starts_with?(integer_part, "0") do
      integer_part == "0"
    else
      not String.ends_with?(number, ".")
    end
  end

  defp to_escaped_codepoint(?b), do: ?\b
  defp to_escaped_codepoint(?t), do: ?\t
  defp to_escaped_codepoint(?n), do: ?\n
  defp to_escaped_codepoint(?f), do: ?\f
  defp to_escaped_codepoint(?r), do: ?\r
  defp to_escaped_codepoint(?\\), do: ?\\
  defp to_escaped_codepoint(?/), do: ?/

  defp to_escaped_codepoint(codepoint) do
    throw(
      {:error,
       %JSONPath.Error{
         type: :unexpected_escaped_codepoint,
         message: "unexpected escaped codepoint: #{<<codepoint>>}"
       }}
    )
  end

  defp safe_integer("-0") do
    {:error, %JSONPath.Error{type: :invalid_number, expression: "-0"}}
  end

  defp safe_integer(number) when is_binary(number) do
    with {:json_compliant, true} <- {:json_compliant, json_compliant_number?(number)},
         {value, ""} <- Integer.parse(number),
         {:safe_index, true} <- {:safe_index, safe_index?(value)} do
      {:ok, value}
    else
      {:json_compliant, false} ->
        {:error,
         %JSONPath.Error{
           type: :invalid_number,
           expression: number,
           message: "number is not JSON-compliant"
         }}

      {:safe_index, false} ->
        {:error,
         %JSONPath.Error{
           type: :invalid_number,
           expression: number,
           message: "number is outside of safe range"
         }}

      _ ->
        {:error,
         %JSONPath.Error{
           type: :invalid_number,
           expression: number,
           message: "invalid integer"
         }}
    end
  end

  defp safe_index?(num), do: num >= -9_007_199_254_740_991 and num <= 9_007_199_254_740_991
end
