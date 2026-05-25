[![CI](https://github.com/IgnacioGoldchluk/json_path/actions/workflows/ci.yml/badge.svg)](https://github.com/IgnacioGoldchluk/json_path/actions/workflows/ci.yml)
[![License](https://img.shields.io/hexpm/l/json_path
)](https://github.com/IgnacioGoldchluk/json_path/blob/main/LICENSE)
[![Version](https://img.shields.io/hexpm/v/json_path.svg)](https://hex.pm/packages/json_path)
[![Docs](https://img.shields.io/badge/documentation-gray.svg)](https://hexdocs.pm/json_path)

# JSONPath

[RFC-9535](https://www.rfc-editor.org/info/rfc9535/) compliant JSONPath query evaluator for Elixir, with 100% passing rate for the [JSONPath Compliance Test Suite](https://github.com/jsonpath-standard/jsonpath-compliance-test-suite)

## Installation
Add `json_path` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:json_path, "~> 0.1.1"}
  ]
end
```

## Usage
`JSONPath` supports string keys only.

You can pass the JSONPath query expression as a string
```elixir
root = [%{"a" => %{"b" => "c"}}, %{"b" => %{"a" => 1}}]
query = "$..a"
JSONPath.evaluate(root, query)
# {:ok, [%{"b" => "c"}, 1]}
```

Or if you plan use the same query multiple times, you can build the expression once for better performance
```elixir
{:ok, query} = JSONPath.build("$[1]")
JSONPath.evaluate([], query)
#{:ok, []}
JSONPath.evaluate(["a", "b", "c"], query)
# {:ok, ["b"]}
```

## Notes and considerations
- JSONPath always returns a list of nodes, as specified by RFC-9535, even for expressions that could return at most one element such as `$.x`.
- Atom keys are not supported.
- JSON Path expects [I-RegExp](https://www.rfc-editor.org/info/rfc9485/) style regular expressions, which are a limited version of regular expressions made to be compatible and easy to implement in most languages. This library instead allows for any Elixir-valid regular expression.
