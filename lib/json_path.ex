defmodule JSONPath do
  @moduledoc """
  [RFC-9535](https://www.rfc-editor.org/rfc/rfc9535) compliant JSON Path evaluator.
  """

  alias JSONPath.{AST, Eval, Tokenizer}

  @type json() :: nil | number() | String.t() | boolean() | [json()] | %{String.t() => json()}

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
  `{:ok, results}` or `{:error, JSONPath.Error.t()}` tuple

  ## Examples

      iex> JSONPath.evaluate(["aba", "bbab", "bab"], "$[?match(@, 'b.b')]")
      {:ok, ["bab"]}

      iex> JSONPath.evaluate(%{"foo" => [1, 2, 3, 4]}, "$.foo[::-1]")
      {:ok, [4, 3, 2, 1]}

      iex> JSONPath.evaluate(%{"foo" => %{"bar" => "baz"}}, "$[?length(@)]")
      {:error, %JSONPath.Error{
        type: :invalid_expression,
        expression: "length(@)",
        message: "comparison operator expected"
        }
      }
  """
  @spec evaluate(json(), String.t() | AST.t()) ::
          {:ok, list(json())} | {:error, JSONPath.Error.t()}
  def evaluate(document, query) when is_binary(query) do
    case build(query) do
      {:ok, ast} -> {:ok, Eval.evaluate(document, ast)}
      error -> error
    end
  end

  def evaluate(document, query), do: {:ok, Eval.evaluate(document, query)}

  @doc """
  Same as `evaluate/2` but raises in case of error
  """
  @spec evaluate!(json(), String.t() | AST.t()) :: list(json())
  def evaluate!(document, query) do
    case evaluate(document, query) do
      {:ok, result} -> result
      {:error, %JSONPath.Error{} = e} -> raise e
    end
  end
end
