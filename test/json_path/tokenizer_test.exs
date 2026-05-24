defmodule JSONPath.TokenizerTest do
  use ExUnit.Case

  alias JSONPath.Tokenizer

  describe "tokenize/1" do
    test "invalid number to compare" do
      query = "$[?@.a==00]"

      error = %JSONPath.Error{
        expression: ~c"00",
        message: "number is not JSON-compliant",
        type: :invalid_number
      }

      assert {:error, error} == Tokenizer.tokenize(query)
    end

    test "slice selector with long form" do
      query = "$[::]"
      expected = [:root, :lbracket, {:slice, nil, nil, 1}, :rbracket]

      assert {:ok, expected} == Tokenizer.tokenize(query)
    end

    test "'+' and brackets are invalid in escaped unicode codepoints" do
      query = "$[\"\\u+1234\"]"

      error = %JSONPath.Error{
        expression: "\\u+123",
        message: "unnecessary '+' and/or '{' in unicode codepoint",
        type: :invalid_unicode
      }

      assert {:error, error} == Tokenizer.tokenize(query)
    end

    test "unnecessary escaped quote" do
      query = "$[\"\\'\"]"

      error = %JSONPath.Error{
        expression: nil,
        message: "unexpected escaped codepoint: '",
        type: :unexpected_escaped_codepoint
      }

      assert {:error, error} == Tokenizer.tokenize(query)
    end

    test "high surrogate outside of range is treated as two codepoints" do
      query = "$[\"\\uD7FF\\uD7FF\"]"
      expected = [:root, :lbracket, {:property, [0xD7FF, 0xD7FF] |> to_string()}, :rbracket]
      assert {:ok, expected} == Tokenizer.tokenize(query)
    end

    test "low surrogate outside of range is treated as two codepoints" do
      query = "$[\"\\uE000\\uE000\"]"
      expected = [:root, :lbracket, {:property, [0xE000, 0xE000] |> to_string()}, :rbracket]
      assert {:ok, expected} == Tokenizer.tokenize(query)
    end

    test "valid surrogate pairs are treated as single codepoint" do
      query = "$['\\uD834\\uDD1E']"
      expected = [:root, :lbracket, {:property, "𝄞"}, :rbracket]
      assert {:ok, expected} == Tokenizer.tokenize(query)
    end

    test "escaped unicode codepoint is converted to its value" do
      query = "$['\\u263A']"

      expected = [:root, :lbracket, {:property, "☺"}, :rbracket]
      assert {:ok, expected} == Tokenizer.tokenize(query)
    end

    test "escaped backslash is valid, embeded is invalid" do
      query = "$[\"\\b\"]"

      expected = [:root, :lbracket, {:property, "\b"}, :rbracket]
      assert {:ok, expected} == Tokenizer.tokenize(query)
      assert {:error, _} = Tokenizer.tokenize("$[\"\b\"]")
    end

    test "property with double backslash" do
      query = "$[\"\\\\\"]"
      expected = [:root, :lbracket, {:property, "\\"}, :rbracket]
      assert {:ok, expected} == Tokenizer.tokenize(query)
    end

    test "nested filter is valid" do
      query = "$[?@[?@>1]]"

      expected = [
        :root,
        :lbracket,
        :filter,
        :current_node,
        :lbracket,
        :filter,
        :current_node,
        :gt,
        {:literal, 1},
        :rbracket,
        :rbracket
      ]

      assert {:ok, expected} == Tokenizer.tokenize(query)
    end

    test "multiple value query in filter function is valid" do
      query = "$[?length(@[1:5]) == 4]"

      expected = [
        :root,
        :lbracket,
        :filter,
        {:function, :length},
        :lparen,
        :current_node,
        :lbracket,
        {:slice, 1, 5, 1},
        :rbracket,
        :rparen,
        :eq,
        {:literal, 4},
        :rbracket
      ]

      assert {:ok, expected} == Tokenizer.tokenize(query)
    end

    test "unicode access property" do
      query = "$.☺"
      expected = [:root, :lbracket, {:property, "☺"}, :rbracket]

      assert {:ok, expected} == Tokenizer.tokenize(query)
    end

    test "slice when first selector is a filter" do
      query = "$[?length(@.foo) == 0, 1:3]"

      expected = [
        :root,
        :lbracket,
        :filter,
        {:function, :length},
        :lparen,
        :current_node,
        :lbracket,
        {:property, "foo"},
        :rbracket,
        :rparen,
        :eq,
        {:literal, 0},
        :comma,
        {:slice, 1, 3, 1},
        :rbracket
      ]

      assert {:ok, expected} == Tokenizer.tokenize(query)
    end

    test "shorthand wildcard for property and descendant segment" do
      query = "$.*..*"

      expected = [
        :root,
        :lbracket,
        :wildcard,
        :rbracket,
        :descendant_segment,
        :lbracket,
        :wildcard,
        :rbracket
      ]

      assert {:ok, expected} == Tokenizer.tokenize(query)
    end

    test "tokenizes special value function" do
      query = "$.value[?value(@['value']) != 0]"

      expected = [
        :root,
        :lbracket,
        {:property, "value"},
        :rbracket,
        :lbracket,
        :filter,
        {:function, :value},
        :lparen,
        :current_node,
        :lbracket,
        {:property, "value"},
        :rbracket,
        :rparen,
        :neq,
        {:literal, 0},
        :rbracket
      ]

      assert {:ok, expected} == Tokenizer.tokenize(query)
    end

    test "tokenizes comparisons" do
      query = "$[?count(@) >= 2]"

      expected = [
        :root,
        :lbracket,
        :filter,
        {:function, :count},
        :lparen,
        :current_node,
        :rparen,
        :gte,
        {:literal, 2},
        :rbracket
      ]

      assert {:ok, expected} == Tokenizer.tokenize(query)
    end

    test "tokenizes regex functions" do
      query = "$[?match(@.x, '[a-z]') || search(@.y, '[0-9]+')]"

      expected = [
        :root,
        :lbracket,
        :filter,
        {:function, :match},
        :lparen,
        :current_node,
        :lbracket,
        {:property, "x"},
        :rbracket,
        :comma,
        {:literal, "[a-z]"},
        :rparen,
        :or,
        {:function, :search},
        :lparen,
        :current_node,
        :lbracket,
        {:property, "y"},
        :rbracket,
        :comma,
        {:literal, "[0-9]+"},
        :rparen,
        :rbracket
      ]

      assert {:ok, expected} == Tokenizer.tokenize(query)
    end

    test "tokenizes special functions" do
      query = "$[?length(@.x) > count(@.foo)]"

      expected = [
        :root,
        :lbracket,
        :filter,
        {:function, :length},
        :lparen,
        :current_node,
        :lbracket,
        {:property, "x"},
        :rbracket,
        :rparen,
        :gt,
        {:function, :count},
        :lparen,
        :current_node,
        :lbracket,
        {:property, "foo"},
        :rbracket,
        :rparen,
        :rbracket
      ]

      assert {:ok, expected} == Tokenizer.tokenize(query)
    end

    test "quoted properties with same quote codepoint" do
      query = "$['fo\\'o']"
      expected = [:root, :lbracket, {:property, "fo\'o"}, :rbracket]
      assert {:ok, expected} == Tokenizer.tokenize(query)
    end

    test "tokenizes special literals" do
      query = "$[?@.x == null || !@.y == false && @.z == true]"

      expected = [
        :root,
        :lbracket,
        :filter,
        :current_node,
        :lbracket,
        {:property, "x"},
        :rbracket,
        :eq,
        {:literal, nil},
        :or,
        :not,
        :current_node,
        :lbracket,
        {:property, "y"},
        :rbracket,
        :eq,
        {:literal, false},
        :and,
        :current_node,
        :lbracket,
        {:property, "z"},
        :rbracket,
        :eq,
        {:literal, true},
        :rbracket
      ]

      assert {:ok, expected} == Tokenizer.tokenize(query)
    end

    test "tokenizes literals" do
      query = "$[?@.foo == 'bar' && @.baz <= 12.3e-4 || @.qux < 15]"

      expected = [
        :root,
        :lbracket,
        :filter,
        :current_node,
        :lbracket,
        {:property, "foo"},
        :rbracket,
        :eq,
        {:literal, "bar"},
        :and,
        :current_node,
        :lbracket,
        {:property, "baz"},
        :rbracket,
        :lte,
        {:literal, 12.3e-4},
        :or,
        :current_node,
        :lbracket,
        {:property, "qux"},
        :rbracket,
        :lt,
        {:literal, 15},
        :rbracket
      ]

      assert {:ok, expected} == Tokenizer.tokenize(query)
    end

    test "tokenizes slices and indexes" do
      query = "$[1, -1, ::-1, 1:2, 1:10:2, :2:3, 50::3, 100::]"

      expected = [
        :root,
        :lbracket,
        {:index, 1},
        :comma,
        {:index, -1},
        :comma,
        {:slice, nil, nil, -1},
        :comma,
        {:slice, 1, 2, 1},
        :comma,
        {:slice, 1, 10, 2},
        :comma,
        {:slice, nil, 2, 3},
        :comma,
        {:slice, 50, nil, 3},
        :comma,
        {:slice, 100, nil, 1},
        :rbracket
      ]

      assert {:ok, expected} == Tokenizer.tokenize(query)
    end

    test "tokenizes descendant segment with and without shorthand" do
      query = "$..foo"
      expected = [:root, :descendant_segment, :lbracket, {:property, "foo"}, :rbracket]
      assert {:ok, expected} == Tokenizer.tokenize(query)

      query = "$..[\"bar\"]"
      expected = [:root, :descendant_segment, :lbracket, {:property, "bar"}, :rbracket]
      assert {:ok, expected} == Tokenizer.tokenize(query)

      query = "$..foo..bar..baz"

      expected = [
        :root,
        :descendant_segment,
        :lbracket,
        {:property, "foo"},
        :rbracket,
        :descendant_segment,
        :lbracket,
        {:property, "bar"},
        :rbracket,
        :descendant_segment,
        :lbracket,
        {:property, "baz"},
        :rbracket
      ]

      assert {:ok, expected} == Tokenizer.tokenize(query)
    end

    test "tokenizes wildcards" do
      query = "$.foo[*, *]"

      expected =
        [
          :root,
          :lbracket,
          {:property, "foo"},
          :rbracket,
          :lbracket,
          :wildcard,
          :comma,
          :wildcard,
          :rbracket
        ]

      assert {:ok, expected} == Tokenizer.tokenize(query)
    end

    test "slice with plus sign returns error" do
      query = "$[:+1:]"

      error = %JSONPath.Error{
        expression: ":+1:",
        message: "unnecessary '+' in index/slice",
        type: :invalid_number
      }

      assert {:error, error} == Tokenizer.tokenize(query)
    end

    test "slice with too many colons returns error" do
      query = "$[1:2:3:4]"

      error = %JSONPath.Error{
        expression: "1:2:3:4",
        message: "invalid slice format",
        type: :invalid_expression
      }

      assert {:error, error} == Tokenizer.tokenize(query)
    end
  end

  describe "whitespaces" do
    test "allowed between numbers indexes and slices" do
      query = "$[     \t\r\n 4   , 1   :\n\n5\r\n\t:  -1 ]"

      expected = [:root, :lbracket, {:index, 4}, :comma, {:slice, 1, 5, -1}, :rbracket]
      assert {:ok, expected} == Tokenizer.tokenize(query)
    end
  end
end
