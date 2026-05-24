defmodule JSONPath.ComplianceTest do
  use ExUnit.Case

  for testcase <-
        Path.join(["test", "cts.json"])
        |> File.read!()
        |> JSON.decode!()
        |> Map.fetch!("tests") do
    if Map.get(testcase, "skip", false) do
      @tag :skip
    end

    test "#{testcase["name"]}" do
      testcase = unquote(Macro.escape(testcase))
      selector = testcase["selector"]
      root = testcase["document"]
      result = testcase["result"]
      results = testcase["results"]

      cond do
        Map.get(testcase, "invalid_selector", false) == true ->
          assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)

        not is_nil(result) ->
          # Only one possible result
          {:ok, value} = JSONPath.evaluate(root, selector)

          assert value == result,
                 "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

        not is_nil(results) ->
          # Multiple results
          {:ok, value} = JSONPath.evaluate(root, selector)
          assert value in results, "no match for query #{selector} and root #{inspect(root)}"

        true ->
          raise "Unexpected testcase format: #{inspect(testcase)}"
      end
    end
  end
end
