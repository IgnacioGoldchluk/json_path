[![CI](https://github.com/IgnacioGoldchluk/json_path/actions/workflows/ci.yml/badge.svg)](https://github.com/IgnacioGoldchluk/json_path/actions/workflows/ci.yml)
[![License](https://img.shields.io/hexpm/l/json_path
)](https://github.com/IgnacioGoldchluk/json_path/blob/main/LICENSE)
[![Version](https://img.shields.io/hexpm/v/json_path.svg)](https://hex.pm/packages/json_path)
[![Docs](https://img.shields.io/badge/documentation-gray.svg)](https://json-path.hexdocs.pm)

# JSONPath

[RFC-9535](https://www.rfc-editor.org/info/rfc9535/) compliant JSONPath query evaluator for Elixir, with 100% passing rate for the [JSONPath Compliance Test Suite](https://github.com/jsonpath-standard/jsonpath-compliance-test-suite)

## Installation
Add `json_path` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:json_path, "~> 0.4"}
  ]
end
```

## Usage
`JSONPath` supports string keys only.

You can pass the JSONPath query expression as a string
```elixir
iex(1)> root = [%{"a" => %{"b" => "c"}}, %{"b" => %{"a" => 1}}]
iex(2)> query = "$..a"
iex(3)> JSONPath.values(root, query)
{:ok, [%{"b" => "c"}, 1]}
```

Or if you plan use the same query multiple times, you can build the expression once for better performance
```elixir
iex(1)> {:ok, query} = JSONPath.build("$[1]")
iex(2)> JSONPath.values([], query)
{:ok, []}

iex(3)> JSONPath.values(["a", "b", "c"], query)
{:ok, ["b"]}
```

Attempting to build invalid JSONPath expressions returns helpful error messages
```elixir
iex(1)> JSONPath.build("$[?length(@.elems)]")
{:error,
 %JSONPath.Error{
   type: :invalid_expression,
   expression: "length(@['elems'])",
   message: "comparison operator expected"
 }}

iex(2)> JSONPath.values([%{"name" => "Alice"}], "$[?match(@.name)]")
{:error,
 %JSONPath.Error{
   type: :invalid_expression,
   expression: "match(@['name'])",
   message: "got 1 argument but 'match' expects 2 arguments"
 }}
```

Retrieving node values, normalized paths or both
```elixir
iex(1)> root = %{"people" => [
...>    %{"name" => "Alice", "age" => 20},
...>    %{"name" => "Bob", "age" => 30}
...>  ]}
iex(2)> query = "$.people[?@.age > 25]"
iex(3)> JSONPath.values(root, query)
{:ok, [%{"name" => "Bob", "age" => 30}]}

iex(4)> JSONPath.paths(root, query)
{:ok, ["$['people'][1]"]}

iex(5)> JSONPath.matches(root, query)
{:ok, [{%{"name" => "Bob", "age" => 30}, "$['people'][1]"}]}
```

## Notes and considerations
- JSONPath always returns a list of nodes, as specified by RFC-9535, even for expressions that could return at most one element such as `$.x`.
- Atom keys are not supported.
- JSON Path expects [I-RegExp](https://www.rfc-editor.org/info/rfc9485/) style regular expressions, which are a limited version of regular expressions made to be compatible and easy to implement in most languages. This library instead allows for any Elixir-valid regular expression.
