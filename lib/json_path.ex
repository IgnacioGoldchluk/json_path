defmodule JSONPath do
  @moduledoc """
  [RFC-9535](https://www.rfc-editor.org/rfc/rfc9535) compliant JSON Path evaluator.
  """

  alias JSONPath.{AST, Eval, Tokenizer}

  @type json() :: nil | number() | String.t() | boolean() | [json()] | %{String.t() => json()}
  @type returning() :: :values | :paths | :values_and_paths

  @doc """
  Builds a JSON Path query `t:JSONPath.AST.t/0`. Returns `{:ok, ast}` or
  `{:error, JSONPath.Error.t()}`.

  Prefer this function when running the same query multiple times, since building the query
  each time performs potentially expensive semantic checks.
  """
  @spec build(String.t()) :: {:ok, JSONPath.AST.t()} | {:error, JSONPath.Error.t()}
  def build(query) when is_binary(query) do
    case Tokenizer.tokenize(query) do
      {:ok, tokens} -> AST.parse(tokens)
      {:error, _} = e -> e
    end
  end

  @doc """
  Same as `build/1` but raises in case of error
  """
  @spec build!(String.t()) :: JSONPath.AST.t()
  def build!(query) when is_binary(query) do
    case build(query) do
      {:ok, ast} -> ast
      {:error, %JSONPath.Error{} = e} -> raise e
    end
  end

  @doc """
  Evaluates a JSON value against the given query string or parsed AST. Returns an
  `{:ok, results}` or `{:error, JSONPath.Error.t()}` tuple.

  The `results` type is controlled by the `returning` argument:
  - `:values` - List of node values. This is the default behavior
  - `:paths` - List of [normalized paths](https://www.rfc-editor.org/info/rfc9535/#name-normalized-paths)
  - `:values_and_paths` - List of tuples `{value, normalized_path}`
  """
  @spec evaluate(json(), String.t() | AST.t(), returning()) ::
          {:ok, list(json())} | {:error, JSONPath.Error.t()}
  @deprecated "Use one of JSONPath.values/2, JSONPath.paths/2 or JSONPath.value_paths/2"
  def evaluate(document, query, returning \\ :values), do: run(document, query, returning)

  defp run(document, query, returning) when is_binary(query) do
    case build(query) do
      {:ok, ast} -> {:ok, Eval.evaluate(document, ast) |> keep(returning)}
      error -> error
    end
  end

  defp run(document, query, returning) do
    {:ok, Eval.evaluate(document, query) |> keep(returning)}
  end

  @doc """
  Evaluates a JSON value against the given query string or parsed AST. Returns a result
  tuple containing the list of matching node values.

  ## Examples
      iex> JSONPath.values(["aba", "bbab", "bab"], "$[?match(@, 'b.b')]")
      {:ok, ["bab"]}

      iex> JSONPath.values(%{"foo" => ["a", "b", "c", "d"]}, "$.foo[::-1]")
      {:ok, ["d", "c", "b", "a"]}

      iex> JSONPath.values(%{"foo" => [1,2,3,4]}, "$.foo[?@ > 2]")
      {:ok, [3, 4]}

      iex> JSONPath.values(%{"foo" => %{"bar" => "baz"}}, "$[?length(@)]")
      {:error, %JSONPath.Error{
        type: :invalid_expression,
        expression: "length(@)",
        message: "comparison operator expected"
        }
      }
  """
  @doc since: "0.4.0"
  @spec values(json(), String.t() | AST.t()) :: {:ok, [json()]} | {:error, JSONPath.Error.t()}
  def values(document, query), do: run(document, query, :values)

  @doc """
  Same as `values/2` but returns the list of nodes values or raises an error

  ## Examples

      iex> JSONPath.values!(%{"foo" => [1,2,3,4]}, "$.foo[?@ > 2]")
      [3, 4]
  """
  @doc since: "0.4.0"
  @spec values!(json(), String.t() | AST.t()) :: [json()]
  def values!(document, query) do
    case values(document, query) do
      {:ok, results} -> results
      {:error, exc} -> raise exc
    end
  end

  @doc """
  Evaluates a JSON value against the given query string or parsed AST. Returns a result
  tuple containing the list of [normalized paths](https://www.rfc-editor.org/info/rfc9535/#name-normalized-paths)

  ## Examples
      iex> JSONPath.paths(["aba", "bbab", "bab"], "$[?match(@, 'b.b')]")
      {:ok, ["$[2]"]}

      iex> JSONPath.paths(%{"foo" => ["a", "b", "c", "d"]}, "$.foo[::-1]")
      {:ok, ["$['foo'][3]", "$['foo'][2]", "$['foo'][1]", "$['foo'][0]"]}
  """
  @spec paths(json(), String.t() | AST.t()) :: {:ok, [String.t()]} | {:error, JSONPath.Error.t()}
  @doc since: "0.4.0"
  def paths(document, query), do: run(document, query, :paths)

  @doc """
  Same as `paths/2` but returns the list of normalized paths or raises an error

  ## Examples
      iex> JSONPath.paths!(["aba", "bbab", "bab"], "$[?match(@, 'b.b')]")
      ["$[2]"]
  """
  @doc since: "0.4.0"
  @spec paths!(json(), String.t() | AST.t()) :: [String.t()]
  def paths!(document, query) do
    case paths(document, query) do
      {:ok, results} -> results
      {:error, exc} -> raise exc
    end
  end

  @doc """
  Evaluates a JSON value against the given query string or parsed AST. Returns a
  result tuple containing two-element tuples of `{node_value, normalized_path}`

  ## Examples
      iex> JSONPath.value_paths(["aba", "bbab", "bab"], "$[?match(@, 'b.b')]")
      {:ok, [{"bab", "$[2]"}]}
  """
  @spec value_paths(json(), String.t() | AST.t()) ::
          {:ok, [{json(), String.t()}]} | {:error, JSONPath.Error.t()}
  @doc since: "0.4.0"
  def value_paths(document, query), do: run(document, query, :values_and_paths)

  @doc """
  Same as `value_paths/2` but returns the list of two-element tuple `{node_value, normalized_path}`
  or raises an error

  ## Examples
      iex> JSONPath.value_paths!(["aba", "bbab", "bab"], "$[?match(@, 'b.b')]")
      [{"bab", "$[2]"}]
  """
  @doc since: "0.4.0"
  @spec value_paths!(json(), String.t() | AST.t()) :: [{json(), String.t()}]
  def value_paths!(document, query) do
    case value_paths(document, query) do
      {:ok, results} -> results
      {:error, exc} -> raise exc
    end
  end

  @doc """
  Same as `evaluate/2` but raises in case of error
  """
  @deprecated "Use one of JSONPath.values!/2, JSONPath.paths!/2 or JSONPath.value_paths!/2"
  @spec evaluate!(json(), String.t() | AST.t(), returning()) :: list(json())
  def evaluate!(document, query, returning \\ :values)

  def evaluate!(document, query, returning) do
    case evaluate(document, query, returning) do
      {:ok, result} -> result
      {:error, %JSONPath.Error{} = e} -> raise e
    end
  end

  defp keep(results, :values), do: Enum.map(results, &elem(&1, 0))

  defp keep(results, :paths), do: Enum.map(results, fn {_value, path} -> to_result_path(path) end)

  defp keep(results, :values_and_paths) do
    Enum.map(results, fn {value, path} -> {value, to_result_path(path)} end)
  end

  defp to_result_path([]), do: "$"

  defp to_result_path(path) when is_list(path) do
    "$" <>
      Enum.map_join(Enum.reverse(path), fn
        val when is_integer(val) -> "[#{val}]"
        val when is_binary(val) -> "['#{escape_codepoints(val)}']"
      end)
  end

  defp escape_codepoints(string) do
    string
    |> String.replace("\\", "\\\\")
    |> String.replace("\b", "\\b")
    |> String.replace("\t", "\\t")
    |> String.replace("\n", "\\n")
    |> String.replace("\f", "\\f")
    |> String.replace("\r", "\\r")
    |> String.replace("'", "\\'")
  end
end
