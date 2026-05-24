defmodule JSONPath.ASTTest do
  use ExUnit.Case

  alias JSONPath.{AST, Tokenizer}

  defp matches_ast(query, ast) do
    {:ok, tokens} = Tokenizer.tokenize(query)
    assert {:ok, ast} == AST.parse(tokens)
  end

  describe "parse/1" do
    test "combined non-singular query in filter" do
      query = "$[?@.a[*].a==0]"
      {:ok, tokens} = Tokenizer.tokenize(query)
      assert {:error, _} = AST.parse(tokens)
    end

    test "multiple value query returns error" do
      query = "$[?@[1,2] == 1]"
      {:ok, tokens} = Tokenizer.tokenize(query)
      assert {:error, _} = AST.parse(tokens)
    end

    test "parses empty root" do
      assert matches_ast("$", {:selectors, :root, :full})
    end

    test "nested property" do
      query = "$.foo.bar"

      expected = {
        :selectors,
        {:selectors, :root, [{:property, "foo"}]},
        [{:property, "bar"}]
      }

      matches_ast(query, expected)
    end

    test "multiple selectors" do
      query = "$[?@.foo == 0, 1:3, 'bar']"

      expected = {
        :selectors,
        :root,
        [
          {:filter, {:eq, {:selectors, :current_node, [{:property, "foo"}]}, {:literal, 0}}},
          {:slice, 1, 3, 1},
          {:property, "bar"}
        ]
      }

      matches_ast(query, expected)
    end

    test "multiple grouped boolean expressions" do
      query = "$[?(@.foo == 1 && @.bar == 2) || @.baz == \"hi\"]"

      expected = {
        :selectors,
        :root,
        [
          {:filter,
           {:or,
            {:and, {:eq, {:selectors, :current_node, [{:property, "foo"}]}, {:literal, 1}},
             {:eq, {:selectors, :current_node, [{:property, "bar"}]}, {:literal, 2}}},
            {:eq, {:selectors, :current_node, [{:property, "baz"}]}, {:literal, "hi"}}}}
        ]
      }

      assert matches_ast(query, expected)
    end

    test "multiple index and wildcard selectors" do
      query = "$[?count(@[0, 3, *]) > 1]"

      expected = {
        :selectors,
        :root,
        [
          {:filter,
           {:gt,
            {:function, :count,
             [
               {:selectors, :current_node,
                [
                  {:index, 0},
                  {:index, 3},
                  :wildcard
                ]}
             ]}, {:literal, 1}}}
        ]
      }

      assert matches_ast(query, expected)
    end

    test "negation and multiple parentheses" do
      query = "$[?!(count(@.foo) == 2)]"

      expected = {
        :selectors,
        :root,
        [
          {:filter,
           {:not,
            {:eq, {:function, :count, [{:selectors, :current_node, [{:property, "foo"}]}]},
             {:literal, 2}}}}
        ]
      }

      assert matches_ast(query, expected)
    end

    test "parses filters" do
      query = "$[?length(@) > 1]"

      expected = {
        :selectors,
        :root,
        [
          {:filter,
           {:gt, {:function, :length, [{:selectors, :current_node, :full}]}, {:literal, 1}}}
        ]
      }

      matches_ast(query, expected)
    end

    test "functions with multiple arguments" do
      query = "$..[?match(@.name, \"[a-z]+\")]"

      expected = {
        :descendant_segment,
        {:selectors, :root, :full},
        [
          {:filter,
           {:function, :match,
            [{:selectors, :current_node, [{:property, "name"}]}, {:literal, "[a-z]+"}]}}
        ]
      }

      matches_ast(query, expected)
    end
  end
end
