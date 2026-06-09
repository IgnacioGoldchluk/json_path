defmodule JSONPathTest do
  use ExUnit.Case

  doctest JSONPath

  describe "filter comparison" do
    test "negative literal filter is invalid" do
      error = %JSONPath.Error{
        expression: "!(1)",
        message: "value in filter must be used in comparison expression",
        type: :invalid_expression
      }

      assert {:error, error} == JSONPath.values(%{}, "$[?!1]")
    end

    test "literal comparison is valid" do
      query = "$[?1 == 1]"
      assert {:ok, [1, 2, 3]} == JSONPath.values([1, 2, 3], query)
    end

    test "ordinal comparisons are invalid for multiple value queries" do
      error = %JSONPath.Error{
        expression: "@[?($)] > 1",
        message: "comparison operator requires single value queries",
        type: :invalid_expression
      }

      assert {:error, error} == JSONPath.values(%{}, "$[?@[?$] > 1]")
    end
  end

  describe "count function" do
    test "literal as argument returns error" do
      error = %JSONPath.Error{
        expression: "1",
        message: "count function requires query or selector as argument",
        type: :unexpected_argument
      }

      assert {:error, error} == JSONPath.values(%{}, "$[?count(1) > 1]")

      error = %JSONPath.Error{
        expression: "true",
        message: "count function requires query or selector as argument",
        type: :unexpected_argument
      }

      assert {:error, error} == JSONPath.values(%{}, "$[?count(true) > 2]")
    end

    test "count with empty slice is 0" do
      query = "$[?count(@[::0]) > 0]"
      root = [[1, 2], [3], []]
      assert {:ok, []} == JSONPath.values(root, query)
    end
  end

  describe "length function" do
    test "length takes single query argument" do
      error = %JSONPath.Error{
        expression: "@[1, 2]",
        message: "length function takes single-query argument",
        type: :unexpected_argument
      }

      assert {:error, error} == JSONPath.values(%{}, "$[?length(@[1, 2])<3]")
    end
  end

  describe "function comparison" do
    test "length requires comparison" do
      error = %JSONPath.Error{
        expression: "length(@)",
        message: "comparison operator expected",
        type: :invalid_expression
      }

      assert {:error, error} == JSONPath.values(%{}, "$[?length(@)]")
    end

    test "count requires comparison" do
      error = %JSONPath.Error{
        expression: "count(@) && @['x'] > 2",
        message: "comparison operator expected",
        type: :invalid_expression
      }

      assert {:error, error} == JSONPath.values(%{}, "$[?count(@) && @.x > 2]")
    end

    test "count accepts descendant segment" do
      query = "$[?count(@..*)>2]"

      assert {:ok, [[1, 2, 3, 4]]} =
               JSONPath.values(%{"a" => [1, 2, 3, 4], "b" => 2, "c" => 3}, query)
    end
  end

  describe "invalid function signatures" do
    test "length takes 1 argument" do
      error = %JSONPath.Error{
        expression: "length(@, @['a'])",
        message: "got 2 arguments but 'length' expects 1 argument",
        type: :invalid_expression
      }

      assert {:error, error} == JSONPath.values(%{}, "$[?length(@, @.a)]")
    end

    test "count takes 1 argument" do
      error = %JSONPath.Error{
        expression: "count(@, @['a'])",
        message: "got 2 arguments but 'count' expects 1 argument",
        type: :invalid_expression
      }

      assert {:error, error} == JSONPath.values(%{}, "$[?count(@, @.a)]")
    end

    test "value takes 1 argument" do
      error = %JSONPath.Error{
        expression: "value(@, @['a'])",
        message: "got 2 arguments but 'value' expects 1 argument",
        type: :invalid_expression
      }

      assert {:error, error} == JSONPath.values(%{}, "$[?value(@, @.a)]")
    end

    test "match and search take 2 arguments" do
      error = %JSONPath.Error{
        expression: "match(@)",
        message: "got 1 argument but 'match' expects 2 arguments",
        type: :invalid_expression
      }

      assert {:error, error} == JSONPath.values(%{}, "$[?match(@)]")

      error = %JSONPath.Error{
        expression: "search(@)",
        message: "got 1 argument but 'search' expects 2 arguments",
        type: :invalid_expression
      }

      assert {:error, error} == JSONPath.values(%{}, "$[?search(@)]")
    end
  end

  describe "match function" do
    test "supports non I-RegExp expressions with groups" do
      # Not supported by RFC-9535, we honor Elixir regex for now
      query = "$[?match(@, '(a)b+')]"
      root = ["aab", "abb", "ab", "a"]

      assert {:ok, ["abb", "ab"]} == JSONPath.values(root, query)
    end

    test "matches only at start of the string" do
      query = "$.values[?match(@, $.regex)]"

      root = %{
        "regex" => "b.?b",
        "values" => ["abc", "bcd", "bab", "bba", "bbab", "b", true, [], %{}]
      }

      assert {:ok, ["bab"]} == JSONPath.values(root, query)
    end

    test "matches escaped characters" do
      query = "$[?match(@, 'a\\\\[b')]"
      root = ["abc", "a[b"]
      assert {:ok, ["a[b"]} == JSONPath.values(root, query)
    end

    test "dot matches unicode characters from official test suite" do
      # Doing it here because the JSON file doesn't format properly and instead
      # renders the empty string
      root = [to_string([2028]), to_string([2029])]
      query = "$[?match(@, '.')]"

      assert {:ok, root} == JSONPath.values(root, query)
    end
  end

  describe "search function" do
    test "accepts runtime expressions as regex" do
      query = "$[?search(@, 'a.b')]"
      root = ["a𐄁bc", "abc", "1", true, [], %{}]
      assert {:ok, ["a𐄁bc"]} == JSONPath.values(root, query)
    end
  end

  describe "slices" do
    test "array with negative default step and defaults limits" do
      assert {:ok, [3, 2, 1, 0]} == JSONPath.values([0, 1, 2, 3], "$[::-1]")
    end

    test "array with negative step an default limits" do
      assert {:ok, [3, 1]} == JSONPath.values([0, 1, 2, 3], "$[::-2]")
    end

    test "negative slice with specified stop" do
      assert {:ok, [3, 2, 1]} == JSONPath.values([0, 1, 2, 3], "$[:0:-1]")
    end

    test "negative slice step with default end" do
      assert {:ok, [2, 1, 0]} == JSONPath.values([0, 1, 2, 3], "$[2::-1]")
    end
  end

  describe "evaluate/2" do
    test "reuses parsed AST" do
      {:ok, query} = JSONPath.build("$..a")

      assert {:ok, [1, "b"]} == JSONPath.values(%{"a" => 1, "c" => %{"a" => "b"}}, query)
      assert {:ok, ["d"]} == JSONPath.values([%{"a" => "d"}], query)
    end
  end

  describe "build!/1" do
    test "returns AST on success" do
      query = "$[1:3]"
      expected_ast = {:selectors, :root, [{:slice, 1, 3, 1}]}
      assert expected_ast == JSONPath.build!(query)
    end

    test "raises on error" do
      query = "$[?length(@)]"

      assert_raise JSONPath.Error,
                   "invalid_expression (comparison operator expected): length(@)",
                   fn -> JSONPath.build!(query) end
    end
  end

  describe "values!/2" do
    test "returns nodelist on success" do
      query = "$[?match(@, 'a*')]"
      document = ["a", "aa", "baaa", ""]
      assert ["a", "aa", ""] == JSONPath.values!(document, query)
    end

    test "raises on error" do
      query = "$[?match(@, '[a')]"
      document = ["a", "aa", "baaa", ""]

      error_msg =
        "invalid_pattern (invalid regex pattern: missing terminating ] for character class): [a"

      assert_raise JSONPath.Error, error_msg, fn -> JSONPath.values!(document, query) end
    end
  end
end
