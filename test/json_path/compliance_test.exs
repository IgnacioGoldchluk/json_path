defmodule JSONPath.ComplianceTest do
  use ExUnit.Case

  test "basic, root" do
    testcase = %{
      "document" => ["first", "second"],
      "name" => "basic, root",
      "result" => [["first", "second"]],
      "result_paths" => ["$"],
      "selector" => "$"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, no leading whitespace" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "basic, no leading whitespace",
      "selector" => " $",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "basic, no trailing whitespace" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "basic, no trailing whitespace",
      "selector" => "$ ",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "basic, name shorthand" do
    testcase = %{
      "document" => %{"a" => "A", "b" => "B"},
      "name" => "basic, name shorthand",
      "result" => ["A"],
      "result_paths" => ["$['a']"],
      "selector" => "$.a"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, name shorthand, extended unicode ☺" do
    testcase = %{
      "document" => %{"b" => "B", "☺" => "A"},
      "name" => "basic, name shorthand, extended unicode ☺",
      "result" => ["A"],
      "result_paths" => ["$['☺']"],
      "selector" => "$.☺"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, name shorthand, underscore" do
    testcase = %{
      "document" => %{"_" => "A", "_foo" => "B"},
      "name" => "basic, name shorthand, underscore",
      "result" => ["A"],
      "result_paths" => ["$['_']"],
      "selector" => "$._"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, name shorthand, symbol" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "basic, name shorthand, symbol",
      "selector" => "$.&"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "basic, name shorthand, number" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "basic, name shorthand, number",
      "selector" => "$.1"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "basic, name shorthand, absent data" do
    testcase = %{
      "document" => %{"a" => "A", "b" => "B"},
      "name" => "basic, name shorthand, absent data",
      "result" => [],
      "result_paths" => [],
      "selector" => "$.c"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, name shorthand, array data" do
    testcase = %{
      "document" => ["first", "second"],
      "name" => "basic, name shorthand, array data",
      "result" => [],
      "result_paths" => [],
      "selector" => "$.a"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, name shorthand, object data, nested" do
    testcase = %{
      "document" => %{"a" => %{"b" => %{"c" => "C"}}},
      "name" => "basic, name shorthand, object data, nested",
      "result" => ["C"],
      "result_paths" => ["$['a']['b']['c']"],
      "selector" => "$.a.b.c"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, wildcard shorthand, object data" do
    testcase = %{
      "document" => %{"a" => "A", "b" => "B"},
      "name" => "basic, wildcard shorthand, object data",
      "results" => [["A", "B"], ["B", "A"]],
      "results_paths" => [["$['a']", "$['b']"], ["$['b']", "$['a']"]],
      "selector" => "$.*"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"results" => results, "results_paths" => results_path} = testcase

    # Multiple results
    {:ok, value} = JSONPath.evaluate(root, selector)
    assert value in results, "no match for query #{selector} and root #{inspect(root)}"
    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)
    assert paths in results_path, "no path match for query #{selector} and root #{inspect(root)}"
  end

  test "basic, wildcard shorthand, array data" do
    testcase = %{
      "document" => ["first", "second"],
      "name" => "basic, wildcard shorthand, array data",
      "result" => ["first", "second"],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$.*"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, wildcard selector, array data" do
    testcase = %{
      "document" => ["first", "second"],
      "name" => "basic, wildcard selector, array data",
      "result" => ["first", "second"],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[*]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, wildcard shorthand, then name shorthand" do
    testcase = %{
      "document" => %{"x" => %{"a" => "Ax", "b" => "Bx"}, "y" => %{"a" => "Ay", "b" => "By"}},
      "name" => "basic, wildcard shorthand, then name shorthand",
      "results" => [["Ax", "Ay"], ["Ay", "Ax"]],
      "results_paths" => [["$['x']['a']", "$['y']['a']"], ["$['y']['a']", "$['x']['a']"]],
      "selector" => "$.*.a"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"results" => results, "results_paths" => results_path} = testcase

    # Multiple results
    {:ok, value} = JSONPath.evaluate(root, selector)
    assert value in results, "no match for query #{selector} and root #{inspect(root)}"
    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)
    assert paths in results_path, "no path match for query #{selector} and root #{inspect(root)}"
  end

  test "basic, multiple selectors" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "basic, multiple selectors",
      "result" => [0, 2],
      "result_paths" => ["$[0]", "$[2]"],
      "selector" => "$[0,2]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, multiple selectors, space instead of comma" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "basic, multiple selectors, space instead of comma",
      "selector" => "$[0 2]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "basic, selector, leading comma" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "basic, selector, leading comma",
      "selector" => "$[,0]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "basic, selector, trailing comma" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "basic, selector, trailing comma",
      "selector" => "$[0,]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "basic, multiple selectors, name and index, array data" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "basic, multiple selectors, name and index, array data",
      "result" => [1],
      "result_paths" => ["$[1]"],
      "selector" => "$['a',1]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, multiple selectors, name and index, object data" do
    testcase = %{
      "document" => %{"a" => 1, "b" => 2},
      "name" => "basic, multiple selectors, name and index, object data",
      "result" => [1],
      "result_paths" => ["$['a']"],
      "selector" => "$['a',1]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, multiple selectors, index and slice" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "basic, multiple selectors, index and slice",
      "result" => [1, 5, 6],
      "result_paths" => ["$[1]", "$[5]", "$[6]"],
      "selector" => "$[1,5:7]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, multiple selectors, index and slice, overlapping" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "basic, multiple selectors, index and slice, overlapping",
      "result" => [1, 0, 1, 2],
      "result_paths" => ["$[1]", "$[0]", "$[1]", "$[2]"],
      "selector" => "$[1,0:3]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, multiple selectors, duplicate index" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "basic, multiple selectors, duplicate index",
      "result" => [1, 1],
      "result_paths" => ["$[1]", "$[1]"],
      "selector" => "$[1,1]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, multiple selectors, wildcard and index" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "basic, multiple selectors, wildcard and index",
      "result" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 1],
      "result_paths" => [
        "$[0]",
        "$[1]",
        "$[2]",
        "$[3]",
        "$[4]",
        "$[5]",
        "$[6]",
        "$[7]",
        "$[8]",
        "$[9]",
        "$[1]"
      ],
      "selector" => "$[*,1]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, multiple selectors, wildcard and name" do
    testcase = %{
      "document" => %{"a" => "A", "b" => "B"},
      "name" => "basic, multiple selectors, wildcard and name",
      "results" => [["A", "B", "A"], ["B", "A", "A"]],
      "results_paths" => [["$['a']", "$['b']", "$['a']"], ["$['b']", "$['a']", "$['a']"]],
      "selector" => "$[*,'a']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"results" => results, "results_paths" => results_path} = testcase

    # Multiple results
    {:ok, value} = JSONPath.evaluate(root, selector)
    assert value in results, "no match for query #{selector} and root #{inspect(root)}"
    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)
    assert paths in results_path, "no path match for query #{selector} and root #{inspect(root)}"
  end

  test "basic, multiple selectors, wildcard and slice" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "basic, multiple selectors, wildcard and slice",
      "result" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1],
      "result_paths" => [
        "$[0]",
        "$[1]",
        "$[2]",
        "$[3]",
        "$[4]",
        "$[5]",
        "$[6]",
        "$[7]",
        "$[8]",
        "$[9]",
        "$[0]",
        "$[1]"
      ],
      "selector" => "$[*,0:2]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, multiple selectors, multiple wildcards" do
    testcase = %{
      "document" => [0, 1, 2],
      "name" => "basic, multiple selectors, multiple wildcards",
      "result" => [0, 1, 2, 0, 1, 2],
      "result_paths" => ["$[0]", "$[1]", "$[2]", "$[0]", "$[1]", "$[2]"],
      "selector" => "$[*,*]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, empty segment" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "basic, empty segment",
      "selector" => "$[]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "basic, descendant segment, index" do
    testcase = %{
      "document" => %{"o" => [0, 1, [2, 3]]},
      "name" => "basic, descendant segment, index",
      "result" => [1, 3],
      "result_paths" => ["$['o'][1]", "$['o'][2][1]"],
      "selector" => "$..[1]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, descendant segment, name shorthand" do
    testcase = %{
      "document" => %{"o" => [%{"a" => "b"}, %{"a" => "c"}]},
      "name" => "basic, descendant segment, name shorthand",
      "result" => ["b", "c"],
      "result_paths" => ["$['o'][0]['a']", "$['o'][1]['a']"],
      "selector" => "$..a"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, name shorthand, true" do
    testcase = %{
      "document" => %{"_foo" => "B", "true" => "A"},
      "name" => "basic, name shorthand, true",
      "result" => ["A"],
      "result_paths" => ["$['true']"],
      "selector" => "$.true",
      "tags" => ["boundary"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, name shorthand, false" do
    testcase = %{
      "document" => %{"_foo" => "B", "false" => "A"},
      "name" => "basic, name shorthand, false",
      "result" => ["A"],
      "result_paths" => ["$['false']"],
      "selector" => "$.false",
      "tags" => ["boundary"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, name shorthand, null" do
    testcase = %{
      "document" => %{"_foo" => "B", "null" => "A"},
      "name" => "basic, name shorthand, null",
      "result" => ["A"],
      "result_paths" => ["$['null']"],
      "selector" => "$.null",
      "tags" => ["boundary"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, descendant segment, wildcard shorthand, array data" do
    testcase = %{
      "document" => [0, 1],
      "name" => "basic, descendant segment, wildcard shorthand, array data",
      "result" => [0, 1],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$..*"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, descendant segment, wildcard selector, array data" do
    testcase = %{
      "document" => [0, 1],
      "name" => "basic, descendant segment, wildcard selector, array data",
      "result" => [0, 1],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$..[*]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, descendant segment, wildcard selector, nested arrays" do
    testcase = %{
      "document" => [[[1]], [2]],
      "name" => "basic, descendant segment, wildcard selector, nested arrays",
      "results" => [[[[1]], [2], [1], 1, 2], [[[1]], [2], [1], 2, 1]],
      "results_paths" => [
        ["$[0]", "$[1]", "$[0][0]", "$[0][0][0]", "$[1][0]"],
        ["$[0]", "$[1]", "$[0][0]", "$[1][0]", "$[0][0][0]"]
      ],
      "selector" => "$..[*]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"results" => results, "results_paths" => results_path} = testcase

    # Multiple results
    {:ok, value} = JSONPath.evaluate(root, selector)
    assert value in results, "no match for query #{selector} and root #{inspect(root)}"
    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)
    assert paths in results_path, "no path match for query #{selector} and root #{inspect(root)}"
  end

  test "basic, descendant segment, wildcard selector, nested objects" do
    testcase = %{
      "document" => %{"a" => %{"c" => %{"e" => 1}}, "b" => %{"d" => 2}},
      "name" => "basic, descendant segment, wildcard selector, nested objects",
      "results" => [
        [%{"c" => %{"e" => 1}}, %{"d" => 2}, %{"e" => 1}, 1, 2],
        [%{"c" => %{"e" => 1}}, %{"d" => 2}, %{"e" => 1}, 2, 1],
        [%{"c" => %{"e" => 1}}, %{"d" => 2}, 2, %{"e" => 1}, 1],
        [%{"d" => 2}, %{"c" => %{"e" => 1}}, %{"e" => 1}, 1, 2],
        [%{"d" => 2}, %{"c" => %{"e" => 1}}, %{"e" => 1}, 2, 1],
        [%{"d" => 2}, %{"c" => %{"e" => 1}}, 2, %{"e" => 1}, 1]
      ],
      "results_paths" => [
        ["$['a']", "$['b']", "$['a']['c']", "$['a']['c']['e']", "$['b']['d']"],
        ["$['a']", "$['b']", "$['a']['c']", "$['b']['d']", "$['a']['c']['e']"],
        ["$['a']", "$['b']", "$['b']['d']", "$['a']['c']", "$['a']['c']['e']"],
        ["$['b']", "$['a']", "$['a']['c']", "$['a']['c']['e']", "$['b']['d']"],
        ["$['b']", "$['a']", "$['a']['c']", "$['b']['d']", "$['a']['c']['e']"],
        ["$['b']", "$['a']", "$['b']['d']", "$['a']['c']", "$['a']['c']['e']"]
      ],
      "selector" => "$..[*]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"results" => results, "results_paths" => results_path} = testcase

    # Multiple results
    {:ok, value} = JSONPath.evaluate(root, selector)
    assert value in results, "no match for query #{selector} and root #{inspect(root)}"
    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)
    assert paths in results_path, "no path match for query #{selector} and root #{inspect(root)}"
  end

  test "basic, descendant segment, wildcard shorthand, object data" do
    testcase = %{
      "document" => %{"a" => "b"},
      "name" => "basic, descendant segment, wildcard shorthand, object data",
      "result" => ["b"],
      "result_paths" => ["$['a']"],
      "selector" => "$..*"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, descendant segment, wildcard shorthand, nested data" do
    testcase = %{
      "document" => %{"o" => [%{"a" => "b"}]},
      "name" => "basic, descendant segment, wildcard shorthand, nested data",
      "result" => [[%{"a" => "b"}], %{"a" => "b"}, "b"],
      "result_paths" => ["$['o']", "$['o'][0]", "$['o'][0]['a']"],
      "selector" => "$..*"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, descendant segment, multiple selectors" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "basic, descendant segment, multiple selectors",
      "result" => ["b", "e", "c", "f"],
      "result_paths" => ["$[0]['a']", "$[0]['d']", "$[1]['a']", "$[1]['d']"],
      "selector" => "$..['a','d']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "basic, descendant segment, object traversal, multiple selectors" do
    testcase = %{
      "document" => %{"x" => %{"a" => "b", "d" => "e"}, "y" => %{"a" => "c", "d" => "f"}},
      "name" => "basic, descendant segment, object traversal, multiple selectors",
      "results" => [["b", "e", "c", "f"], ["c", "f", "b", "e"]],
      "results_paths" => [
        ["$['x']['a']", "$['x']['d']", "$['y']['a']", "$['y']['d']"],
        ["$['y']['a']", "$['y']['d']", "$['x']['a']", "$['x']['d']"]
      ],
      "selector" => "$..['a','d']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"results" => results, "results_paths" => results_path} = testcase

    # Multiple results
    {:ok, value} = JSONPath.evaluate(root, selector)
    assert value in results, "no match for query #{selector} and root #{inspect(root)}"
    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)
    assert paths in results_path, "no path match for query #{selector} and root #{inspect(root)}"
  end

  test "basic, bald descendant segment" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "basic, bald descendant segment",
      "selector" => "$.."
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "basic, current node identifier without filter selector" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "basic, current node identifier without filter selector",
      "selector" => "$[@.a]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "basic, root node identifier in brackets without filter selector" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "basic, root node identifier in brackets without filter selector",
      "selector" => "$[$.a]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, existence, without segments" do
    testcase = %{
      "document" => %{"a" => 1, "b" => nil},
      "name" => "filter, existence, without segments",
      "results" => [[1, nil], [nil, 1]],
      "results_paths" => [["$['a']", "$['b']"], ["$['b']", "$['a']"]],
      "selector" => "$[?@]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"results" => results, "results_paths" => results_path} = testcase

    # Multiple results
    {:ok, value} = JSONPath.evaluate(root, selector)
    assert value in results, "no match for query #{selector} and root #{inspect(root)}"
    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)
    assert paths in results_path, "no path match for query #{selector} and root #{inspect(root)}"
  end

  test "filter, existence" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "name" => "filter, existence",
      "result" => [%{"a" => "b", "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, existence, present with null" do
    testcase = %{
      "document" => [%{"a" => nil, "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "name" => "filter, existence, present with null",
      "result" => [%{"a" => nil, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, absolute existence, without segments" do
    testcase = %{
      "document" => %{"a" => 1, "b" => nil},
      "name" => "filter, absolute existence, without segments",
      "results" => [[1, nil], [nil, 1]],
      "results_paths" => [["$['a']", "$['b']"], ["$['b']", "$['a']"]],
      "selector" => "$[?$]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"results" => results, "results_paths" => results_path} = testcase

    # Multiple results
    {:ok, value} = JSONPath.evaluate(root, selector)
    assert value in results, "no match for query #{selector} and root #{inspect(root)}"
    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)
    assert paths in results_path, "no path match for query #{selector} and root #{inspect(root)}"
  end

  test "filter, absolute existence, with segments" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "name" => "filter, absolute existence, with segments",
      "result" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?$.*.a]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals string, single quotes" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, equals string, single quotes",
      "result" => [%{"a" => "b", "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a=='b']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals numeric string, single quotes" do
    testcase = %{
      "document" => [%{"a" => "1", "d" => "e"}, %{"a" => 1, "d" => "f"}],
      "name" => "filter, equals numeric string, single quotes",
      "result" => [%{"a" => "1", "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a=='1']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals string, double quotes" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, equals string, double quotes",
      "result" => [%{"a" => "b", "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==\"b\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals numeric string, double quotes" do
    testcase = %{
      "document" => [%{"a" => "1", "d" => "e"}, %{"a" => 1, "d" => "f"}],
      "name" => "filter, equals numeric string, double quotes",
      "result" => [%{"a" => "1", "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==\"1\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals number" do
    testcase = %{
      "document" => [
        %{"a" => 1, "d" => "e"},
        %{"a" => "c", "d" => "f"},
        %{"a" => 2, "d" => "f"},
        %{"a" => "1", "d" => "f"}
      ],
      "name" => "filter, equals number",
      "result" => [%{"a" => 1, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==1]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals null" do
    testcase = %{
      "document" => [%{"a" => nil, "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, equals null",
      "result" => [%{"a" => nil, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==null]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals null, absent from data" do
    testcase = %{
      "document" => [%{"d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, equals null, absent from data",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[?@.a==null]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals true" do
    testcase = %{
      "document" => [%{"a" => true, "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, equals true",
      "result" => [%{"a" => true, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==true]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals false" do
    testcase = %{
      "document" => [%{"a" => false, "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, equals false",
      "result" => [%{"a" => false, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==false]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals self" do
    testcase = %{
      "document" => [1, nil, true, %{"a" => "b"}, [false]],
      "name" => "filter, equals self",
      "result" => [1, nil, true, %{"a" => "b"}, [false]],
      "result_paths" => ["$[0]", "$[1]", "$[2]", "$[3]", "$[4]"],
      "selector" => "$[?@==@]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, absolute, equals self" do
    testcase = %{
      "document" => [1, nil, true, %{"a" => "b"}, [false]],
      "name" => "filter, absolute, equals self",
      "result" => [1, nil, true, %{"a" => "b"}, [false]],
      "result_paths" => ["$[0]", "$[1]", "$[2]", "$[3]", "$[4]"],
      "selector" => "$[?$==$]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals, absent from index selector equals absent from name selector" do
    testcase = %{
      "document" => [%{"list" => [1]}],
      "name" => "filter, equals, absent from index selector equals absent from name selector",
      "result" => [%{"list" => [1]}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.absent==@.list[9]]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, deep equality, arrays" do
    testcase = %{
      "document" => [
        %{"a" => false, "b" => [1, 2]},
        %{"a" => [[1, [2]]], "b" => [[1, [2]]]},
        %{"a" => [[1, [2]]], "b" => [[[2], 1]]},
        %{"a" => [[1, [2]]], "b" => [[1, 2]]}
      ],
      "name" => "filter, deep equality, arrays",
      "result" => [%{"a" => [[1, [2]]], "b" => [[1, [2]]]}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a==@.b]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, deep equality, objects" do
    testcase = %{
      "document" => [
        %{"a" => false, "b" => %{"x" => 1, "y" => %{"z" => 1}}},
        %{"a" => %{"x" => 1, "y" => %{"z" => 1}}, "b" => %{"x" => 1, "y" => %{"z" => 1}}},
        %{"a" => %{"x" => 1, "y" => %{"z" => 1}}, "b" => %{"x" => 1, "y" => %{"z" => 1}}},
        %{"a" => %{"x" => 1, "y" => %{"z" => 1}}, "b" => %{"x" => 1}},
        %{"a" => %{"x" => 1, "y" => %{"z" => 1}}, "b" => %{"x" => 1, "y" => %{"z" => 2}}}
      ],
      "name" => "filter, deep equality, objects",
      "result" => [
        %{"a" => %{"x" => 1, "y" => %{"z" => 1}}, "b" => %{"x" => 1, "y" => %{"z" => 1}}},
        %{"a" => %{"x" => 1, "y" => %{"z" => 1}}, "b" => %{"x" => 1, "y" => %{"z" => 1}}}
      ],
      "result_paths" => ["$[1]", "$[2]"],
      "selector" => "$[?@.a==@.b]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, not-equals string, single quotes" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, not-equals string, single quotes",
      "result" => [%{"a" => "c", "d" => "f"}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a!='b']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, not-equals numeric string, single quotes" do
    testcase = %{
      "document" => [%{"a" => "1", "d" => "e"}, %{"a" => 1, "d" => "f"}],
      "name" => "filter, not-equals numeric string, single quotes",
      "result" => [%{"a" => 1, "d" => "f"}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a!='1']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, not-equals string, single quotes, different type" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"a" => 1, "d" => "f"}],
      "name" => "filter, not-equals string, single quotes, different type",
      "result" => [%{"a" => 1, "d" => "f"}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a!='b']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, not-equals string, double quotes" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, not-equals string, double quotes",
      "result" => [%{"a" => "c", "d" => "f"}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a!=\"b\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, not-equals numeric string, double quotes" do
    testcase = %{
      "document" => [%{"a" => "1", "d" => "e"}, %{"a" => 1, "d" => "f"}],
      "name" => "filter, not-equals numeric string, double quotes",
      "result" => [%{"a" => 1, "d" => "f"}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a!=\"1\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, not-equals string, double quotes, different types" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"a" => 1, "d" => "f"}],
      "name" => "filter, not-equals string, double quotes, different types",
      "result" => [%{"a" => 1, "d" => "f"}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a!=\"b\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, not-equals number" do
    testcase = %{
      "document" => [%{"a" => 1, "d" => "e"}, %{"a" => 2, "d" => "f"}, %{"a" => "1", "d" => "f"}],
      "name" => "filter, not-equals number",
      "result" => [%{"a" => 2, "d" => "f"}, %{"a" => "1", "d" => "f"}],
      "result_paths" => ["$[1]", "$[2]"],
      "selector" => "$[?@.a!=1]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, not-equals number, different types" do
    testcase = %{
      "document" => [%{"a" => 1, "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, not-equals number, different types",
      "result" => [%{"a" => "c", "d" => "f"}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a!=1]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, not-equals null" do
    testcase = %{
      "document" => [%{"a" => nil, "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, not-equals null",
      "result" => [%{"a" => "c", "d" => "f"}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a!=null]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, not-equals null, absent from data" do
    testcase = %{
      "document" => [%{"d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, not-equals null, absent from data",
      "result" => [%{"d" => "e"}, %{"a" => "c", "d" => "f"}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.a!=null]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, not-equals true" do
    testcase = %{
      "document" => [%{"a" => true, "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, not-equals true",
      "result" => [%{"a" => "c", "d" => "f"}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a!=true]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, not-equals false" do
    testcase = %{
      "document" => [%{"a" => false, "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, not-equals false",
      "result" => [%{"a" => "c", "d" => "f"}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a!=false]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, less than string, single quotes" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, less than string, single quotes",
      "result" => [%{"a" => "b", "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a<'c']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, less than string, double quotes" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, less than string, double quotes",
      "result" => [%{"a" => "b", "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a<\"c\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, less than number" do
    testcase = %{
      "document" => [
        %{"a" => 1, "d" => "e"},
        %{"a" => 10, "d" => "e"},
        %{"a" => "c", "d" => "f"},
        %{"a" => 20, "d" => "f"}
      ],
      "name" => "filter, less than number",
      "result" => [%{"a" => 1, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a<10]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, less than null" do
    testcase = %{
      "document" => [%{"a" => nil, "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, less than null",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[?@.a<null]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, less than true" do
    testcase = %{
      "document" => [%{"a" => true, "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, less than true",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[?@.a<true]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, less than false" do
    testcase = %{
      "document" => [%{"a" => false, "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, less than false",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[?@.a<false]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, less than or equal to string, single quotes" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, less than or equal to string, single quotes",
      "result" => [%{"a" => "b", "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.a<='c']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, less than or equal to string, double quotes" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, less than or equal to string, double quotes",
      "result" => [%{"a" => "b", "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.a<=\"c\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, less than or equal to number" do
    testcase = %{
      "document" => [
        %{"a" => 1, "d" => "e"},
        %{"a" => 10, "d" => "e"},
        %{"a" => "c", "d" => "f"},
        %{"a" => 20, "d" => "f"}
      ],
      "name" => "filter, less than or equal to number",
      "result" => [%{"a" => 1, "d" => "e"}, %{"a" => 10, "d" => "e"}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.a<=10]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, less than or equal to null" do
    testcase = %{
      "document" => [%{"a" => nil, "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, less than or equal to null",
      "result" => [%{"a" => nil, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a<=null]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, less than or equal to true" do
    testcase = %{
      "document" => [%{"a" => true, "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, less than or equal to true",
      "result" => [%{"a" => true, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a<=true]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, less than or equal to false" do
    testcase = %{
      "document" => [%{"a" => false, "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, less than or equal to false",
      "result" => [%{"a" => false, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a<=false]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, greater than string, single quotes" do
    testcase = %{
      "document" => [
        %{"a" => "b", "d" => "e"},
        %{"a" => "c", "d" => "f"},
        %{"a" => "d", "d" => "f"}
      ],
      "name" => "filter, greater than string, single quotes",
      "result" => [%{"a" => "d", "d" => "f"}],
      "result_paths" => ["$[2]"],
      "selector" => "$[?@.a>'c']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, greater than string, double quotes" do
    testcase = %{
      "document" => [
        %{"a" => "b", "d" => "e"},
        %{"a" => "c", "d" => "f"},
        %{"a" => "d", "d" => "f"}
      ],
      "name" => "filter, greater than string, double quotes",
      "result" => [%{"a" => "d", "d" => "f"}],
      "result_paths" => ["$[2]"],
      "selector" => "$[?@.a>\"c\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, greater than number" do
    testcase = %{
      "document" => [
        %{"a" => 1, "d" => "e"},
        %{"a" => 10, "d" => "e"},
        %{"a" => "c", "d" => "f"},
        %{"a" => 20, "d" => "f"}
      ],
      "name" => "filter, greater than number",
      "result" => [%{"a" => 20, "d" => "f"}],
      "result_paths" => ["$[3]"],
      "selector" => "$[?@.a>10]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, greater than null" do
    testcase = %{
      "document" => [%{"a" => nil, "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, greater than null",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[?@.a>null]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, greater than true" do
    testcase = %{
      "document" => [%{"a" => true, "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, greater than true",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[?@.a>true]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, greater than false" do
    testcase = %{
      "document" => [%{"a" => false, "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, greater than false",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[?@.a>false]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, greater than or equal to string, single quotes" do
    testcase = %{
      "document" => [
        %{"a" => "b", "d" => "e"},
        %{"a" => "c", "d" => "f"},
        %{"a" => "d", "d" => "f"}
      ],
      "name" => "filter, greater than or equal to string, single quotes",
      "result" => [%{"a" => "c", "d" => "f"}, %{"a" => "d", "d" => "f"}],
      "result_paths" => ["$[1]", "$[2]"],
      "selector" => "$[?@.a>='c']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, greater than or equal to string, double quotes" do
    testcase = %{
      "document" => [
        %{"a" => "b", "d" => "e"},
        %{"a" => "c", "d" => "f"},
        %{"a" => "d", "d" => "f"}
      ],
      "name" => "filter, greater than or equal to string, double quotes",
      "result" => [%{"a" => "c", "d" => "f"}, %{"a" => "d", "d" => "f"}],
      "result_paths" => ["$[1]", "$[2]"],
      "selector" => "$[?@.a>=\"c\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, greater than or equal to number" do
    testcase = %{
      "document" => [
        %{"a" => 1, "d" => "e"},
        %{"a" => 10, "d" => "e"},
        %{"a" => "c", "d" => "f"},
        %{"a" => 20, "d" => "f"}
      ],
      "name" => "filter, greater than or equal to number",
      "result" => [%{"a" => 10, "d" => "e"}, %{"a" => 20, "d" => "f"}],
      "result_paths" => ["$[1]", "$[3]"],
      "selector" => "$[?@.a>=10]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, greater than or equal to null" do
    testcase = %{
      "document" => [%{"a" => nil, "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, greater than or equal to null",
      "result" => [%{"a" => nil, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a>=null]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, greater than or equal to true" do
    testcase = %{
      "document" => [%{"a" => true, "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, greater than or equal to true",
      "result" => [%{"a" => true, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a>=true]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, greater than or equal to false" do
    testcase = %{
      "document" => [%{"a" => false, "d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, greater than or equal to false",
      "result" => [%{"a" => false, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a>=false]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, exists and not-equals null, absent from data" do
    testcase = %{
      "document" => [%{"d" => "e"}, %{"a" => "c", "d" => "f"}],
      "name" => "filter, exists and not-equals null, absent from data",
      "result" => [%{"a" => "c", "d" => "f"}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a&&@.a!=null]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, exists and exists, data false" do
    testcase = %{
      "document" => [%{"a" => false, "b" => false}, %{"b" => false}, %{"c" => false}],
      "name" => "filter, exists and exists, data false",
      "result" => [%{"a" => false, "b" => false}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a&&@.b]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, exists or exists, data false" do
    testcase = %{
      "document" => [%{"a" => false, "b" => false}, %{"b" => false}, %{"c" => false}],
      "name" => "filter, exists or exists, data false",
      "result" => [%{"a" => false, "b" => false}, %{"b" => false}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.a||@.b]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, and" do
    testcase = %{
      "document" => [%{"a" => -10, "d" => "e"}, %{"a" => 5, "d" => "f"}, %{"a" => 20, "d" => "f"}],
      "name" => "filter, and",
      "result" => [%{"a" => 5, "d" => "f"}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a>0&&@.a<10]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, or" do
    testcase = %{
      "document" => [
        %{"a" => "a", "d" => "e"},
        %{"a" => "b", "d" => "f"},
        %{"a" => "c", "d" => "f"},
        %{"a" => "d", "d" => "f"}
      ],
      "name" => "filter, or",
      "result" => [%{"a" => "b", "d" => "f"}, %{"a" => "d", "d" => "f"}],
      "result_paths" => ["$[1]", "$[3]"],
      "selector" => "$[?@.a=='b'||@.a=='d']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, not expression" do
    testcase = %{
      "document" => [
        %{"a" => "a", "d" => "e"},
        %{"a" => "b", "d" => "f"},
        %{"a" => "d", "d" => "f"}
      ],
      "name" => "filter, not expression",
      "result" => [%{"a" => "a", "d" => "e"}, %{"a" => "d", "d" => "f"}],
      "result_paths" => ["$[0]", "$[2]"],
      "selector" => "$[?!(@.a=='b')]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, not exists" do
    testcase = %{
      "document" => [%{"a" => "a", "d" => "e"}, %{"d" => "f"}, %{"a" => "d", "d" => "f"}],
      "name" => "filter, not exists",
      "result" => [%{"d" => "f"}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?!@.a]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, not exists, data null" do
    testcase = %{
      "document" => [%{"a" => nil, "d" => "e"}, %{"d" => "f"}, %{"a" => "d", "d" => "f"}],
      "name" => "filter, not exists, data null",
      "result" => [%{"d" => "f"}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?!@.a]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, non-singular existence, wildcard" do
    testcase = %{
      "document" => [1, [], [2], %{}, %{"a" => 3}],
      "name" => "filter, non-singular existence, wildcard",
      "result" => [[2], %{"a" => 3}],
      "result_paths" => ["$[2]", "$[4]"],
      "selector" => "$[?@.*]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, non-singular existence, multiple" do
    testcase = %{
      "document" => [1, [], [2], [2, 3], %{"a" => 3}, %{"b" => 4}, %{"a" => 3, "b" => 4}],
      "name" => "filter, non-singular existence, multiple",
      "result" => [[2], [2, 3], %{"a" => 3}, %{"a" => 3, "b" => 4}],
      "result_paths" => ["$[2]", "$[3]", "$[4]", "$[6]"],
      "selector" => "$[?@[0, 0, 'a']]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, non-singular existence, slice" do
    testcase = %{
      "document" => [1, [], [2], [2, 3, 4], %{}, %{"a" => 3}],
      "name" => "filter, non-singular existence, slice",
      "result" => [[2], [2, 3, 4]],
      "result_paths" => ["$[2]", "$[3]"],
      "selector" => "$[?@[0:2]]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, non-singular existence, negated" do
    testcase = %{
      "document" => [1, [], [2], %{}, %{"a" => 3}],
      "name" => "filter, non-singular existence, negated",
      "result" => [1, [], %{}],
      "result_paths" => ["$[0]", "$[1]", "$[3]"],
      "selector" => "$[?!@.*]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, non-singular query in comparison, slice" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, non-singular query in comparison, slice",
      "selector" => "$[?@[0:0]==0]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, non-singular query in comparison, all children" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, non-singular query in comparison, all children",
      "selector" => "$[?@[*]==0]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, non-singular query in comparison, descendants" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, non-singular query in comparison, descendants",
      "selector" => "$[?@..a==0]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, non-singular query in comparison, combined" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, non-singular query in comparison, combined",
      "selector" => "$[?@.a[*].a==0]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, nested" do
    testcase = %{
      "document" => [[0], [0, 1], [0, 1, 2], ~c"*"],
      "name" => "filter, nested",
      "result" => [[0, 1, 2], ~c"*"],
      "result_paths" => ["$[2]", "$[3]"],
      "selector" => "$[?@[?@>1]]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, name segment on primitive, selects nothing" do
    testcase = %{
      "document" => %{"a" => 1},
      "name" => "filter, name segment on primitive, selects nothing",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[?@.a == 1]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, name segment on array, selects nothing" do
    testcase = %{
      "document" => [[5, 6]],
      "name" => "filter, name segment on array, selects nothing",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[?@['0'] == 5]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, index segment on object, selects nothing" do
    testcase = %{
      "document" => [%{"0" => 5}],
      "name" => "filter, index segment on object, selects nothing",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[?@[0] == 5]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, followed by name selector" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => %{"x" => 2}}],
      "name" => "filter, followed by name selector",
      "result" => [2],
      "result_paths" => ["$[0]['b']['x']"],
      "selector" => "$[?@.a==1].b.x"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, followed by child segment that selects multiple elements" do
    testcase = %{
      "document" => [%{"x" => 1, "y" => nil, "z" => "_"}],
      "name" => "filter, followed by child segment that selects multiple elements",
      "result" => [1, nil],
      "result_paths" => ["$[0]['x']", "$[0]['y']"],
      "selector" => "$[?@.z=='_']['x','y']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, relative non-singular query, index, equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, relative non-singular query, index, equal",
      "selector" => "$[?(@[0, 0]==42)]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, relative non-singular query, index, not equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, relative non-singular query, index, not equal",
      "selector" => "$[?(@[0, 0]!=42)]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, relative non-singular query, index, less-or-equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, relative non-singular query, index, less-or-equal",
      "selector" => "$[?(@[0, 0]<=42)]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, relative non-singular query, name, equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, relative non-singular query, name, equal",
      "selector" => "$[?(@['a', 'a']==42)]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, relative non-singular query, name, not equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, relative non-singular query, name, not equal",
      "selector" => "$[?(@['a', 'a']!=42)]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, relative non-singular query, name, less-or-equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, relative non-singular query, name, less-or-equal",
      "selector" => "$[?(@['a', 'a']<=42)]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, relative non-singular query, combined, equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, relative non-singular query, combined, equal",
      "selector" => "$[?(@[0, '0']==42)]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, relative non-singular query, combined, not equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, relative non-singular query, combined, not equal",
      "selector" => "$[?(@[0, '0']!=42)]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, relative non-singular query, combined, less-or-equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, relative non-singular query, combined, less-or-equal",
      "selector" => "$[?(@[0, '0']<=42)]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, relative non-singular query, wildcard, equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, relative non-singular query, wildcard, equal",
      "selector" => "$[?(@.*==42)]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, relative non-singular query, wildcard, not equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, relative non-singular query, wildcard, not equal",
      "selector" => "$[?(@.*!=42)]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, relative non-singular query, wildcard, less-or-equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, relative non-singular query, wildcard, less-or-equal",
      "selector" => "$[?(@.*<=42)]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, relative non-singular query, slice, equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, relative non-singular query, slice, equal",
      "selector" => "$[?(@[0:0]==42)]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, relative non-singular query, slice, not equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, relative non-singular query, slice, not equal",
      "selector" => "$[?(@[0:0]!=42)]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, relative non-singular query, slice, less-or-equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, relative non-singular query, slice, less-or-equal",
      "selector" => "$[?(@[0:0]<=42)]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, absolute non-singular query, index, equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, absolute non-singular query, index, equal",
      "selector" => "$[?($[0, 0]==42)]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, absolute non-singular query, index, not equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, absolute non-singular query, index, not equal",
      "selector" => "$[?($[0, 0]!=42)]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, absolute non-singular query, index, less-or-equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, absolute non-singular query, index, less-or-equal",
      "selector" => "$[?($[0, 0]<=42)]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, absolute non-singular query, name, equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, absolute non-singular query, name, equal",
      "selector" => "$[?($['a', 'a']==42)]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, absolute non-singular query, name, not equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, absolute non-singular query, name, not equal",
      "selector" => "$[?($['a', 'a']!=42)]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, absolute non-singular query, name, less-or-equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, absolute non-singular query, name, less-or-equal",
      "selector" => "$[?($['a', 'a']<=42)]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, absolute non-singular query, combined, equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, absolute non-singular query, combined, equal",
      "selector" => "$[?($[0, '0']==42)]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, absolute non-singular query, combined, not equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, absolute non-singular query, combined, not equal",
      "selector" => "$[?($[0, '0']!=42)]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, absolute non-singular query, combined, less-or-equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, absolute non-singular query, combined, less-or-equal",
      "selector" => "$[?($[0, '0']<=42)]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, absolute non-singular query, wildcard, equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, absolute non-singular query, wildcard, equal",
      "selector" => "$[?($.*==42)]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, absolute non-singular query, wildcard, not equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, absolute non-singular query, wildcard, not equal",
      "selector" => "$[?($.*!=42)]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, absolute non-singular query, wildcard, less-or-equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, absolute non-singular query, wildcard, less-or-equal",
      "selector" => "$[?($.*<=42)]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, absolute non-singular query, slice, equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, absolute non-singular query, slice, equal",
      "selector" => "$[?($[0:0]==42)]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, absolute non-singular query, slice, not equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, absolute non-singular query, slice, not equal",
      "selector" => "$[?($[0:0]!=42)]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, absolute non-singular query, slice, less-or-equal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, absolute non-singular query, slice, less-or-equal",
      "selector" => "$[?($[0:0]<=42)]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, multiple selectors" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "name" => "filter, multiple selectors",
      "result" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.a,?@.b]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, multiple selectors, comparison" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "name" => "filter, multiple selectors, comparison",
      "result" => [%{"a" => "b", "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a=='b',?@.b=='x']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, multiple selectors, overlapping" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "name" => "filter, multiple selectors, overlapping",
      "result" => [
        %{"a" => "b", "d" => "e"},
        %{"a" => "b", "d" => "e"},
        %{"b" => "c", "d" => "f"}
      ],
      "result_paths" => ["$[0]", "$[0]", "$[1]"],
      "selector" => "$[?@.a,?@.d]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, multiple selectors, filter and index" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "name" => "filter, multiple selectors, filter and index",
      "result" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.a,1]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, multiple selectors, filter and wildcard" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "name" => "filter, multiple selectors, filter and wildcard",
      "result" => [
        %{"a" => "b", "d" => "e"},
        %{"a" => "b", "d" => "e"},
        %{"b" => "c", "d" => "f"}
      ],
      "result_paths" => ["$[0]", "$[0]", "$[1]"],
      "selector" => "$[?@.a,*]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, multiple selectors, filter and slice" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}, %{"g" => "h"}],
      "name" => "filter, multiple selectors, filter and slice",
      "result" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}, %{"g" => "h"}],
      "result_paths" => ["$[0]", "$[1]", "$[2]"],
      "selector" => "$[?@.a,1:]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, multiple selectors, comparison filter, index and slice" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "name" => "filter, multiple selectors, comparison filter, index and slice",
      "result" => [
        %{"b" => "c", "d" => "f"},
        %{"a" => "b", "d" => "e"},
        %{"b" => "c", "d" => "f"}
      ],
      "result_paths" => ["$[1]", "$[0]", "$[1]"],
      "selector" => "$[1, ?@.a=='b', 1:]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals number, zero and negative zero" do
    testcase = %{
      "document" => [
        %{"a" => 0, "d" => "e"},
        %{"a" => 0.1, "d" => "f"},
        %{"a" => "0", "d" => "g"}
      ],
      "name" => "filter, equals number, zero and negative zero",
      "result" => [%{"a" => 0, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==0]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals number, negative zero and zero" do
    testcase = %{
      "document" => [
        %{"a" => 0, "d" => "e"},
        %{"a" => 0.1, "d" => "f"},
        %{"a" => "0", "d" => "g"}
      ],
      "name" => "filter, equals number, negative zero and zero",
      "result" => [%{"a" => 0, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==-0]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals number, with and without decimal fraction" do
    testcase = %{
      "document" => [%{"a" => 1, "d" => "e"}, %{"a" => 2, "d" => "f"}, %{"a" => "1", "d" => "g"}],
      "name" => "filter, equals number, with and without decimal fraction",
      "result" => [%{"a" => 1, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==1.0]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals number, exponent" do
    testcase = %{
      "document" => [
        %{"a" => 100, "d" => "e"},
        %{"a" => 100.1, "d" => "f"},
        %{"a" => "100", "d" => "g"}
      ],
      "name" => "filter, equals number, exponent",
      "result" => [%{"a" => 100, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==1e2]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals number, exponent upper e" do
    testcase = %{
      "document" => [
        %{"a" => 100, "d" => "e"},
        %{"a" => 100.1, "d" => "f"},
        %{"a" => "100", "d" => "g"}
      ],
      "name" => "filter, equals number, exponent upper e",
      "result" => [%{"a" => 100, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==1E2]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals number, positive exponent" do
    testcase = %{
      "document" => [
        %{"a" => 100, "d" => "e"},
        %{"a" => 100.1, "d" => "f"},
        %{"a" => "100", "d" => "g"}
      ],
      "name" => "filter, equals number, positive exponent",
      "result" => [%{"a" => 100, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==1e+2]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals number, negative exponent" do
    testcase = %{
      "document" => [
        %{"a" => 0.01, "d" => "e"},
        %{"a" => 0.02, "d" => "f"},
        %{"a" => "0.01", "d" => "g"}
      ],
      "name" => "filter, equals number, negative exponent",
      "result" => [%{"a" => 0.01, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==1e-2]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals number, exponent 0" do
    testcase = %{
      "document" => [%{"a" => 1, "d" => "e"}, %{"a" => 2, "d" => "f"}, %{"a" => "1", "d" => "g"}],
      "name" => "filter, equals number, exponent 0",
      "result" => [%{"a" => 1, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==1e0]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals number, exponent -0" do
    testcase = %{
      "document" => [%{"a" => 1, "d" => "e"}, %{"a" => 2, "d" => "f"}, %{"a" => "1", "d" => "g"}],
      "name" => "filter, equals number, exponent -0",
      "result" => [%{"a" => 1, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==1e-0]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals number, exponent +0" do
    testcase = %{
      "document" => [%{"a" => 1, "d" => "e"}, %{"a" => 2, "d" => "f"}, %{"a" => "1", "d" => "g"}],
      "name" => "filter, equals number, exponent +0",
      "result" => [%{"a" => 1, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==1e+0]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals number, exponent leading -0" do
    testcase = %{
      "document" => [
        %{"a" => 0.01, "d" => "e"},
        %{"a" => 0.02, "d" => "f"},
        %{"a" => "0.01", "d" => "g"}
      ],
      "name" => "filter, equals number, exponent leading -0",
      "result" => [%{"a" => 0.01, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==1e-02]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals number, exponent +00" do
    testcase = %{
      "document" => [%{"a" => 1, "d" => "e"}, %{"a" => 2, "d" => "f"}, %{"a" => "1", "d" => "g"}],
      "name" => "filter, equals number, exponent +00",
      "result" => [%{"a" => 1, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==1e+00]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals number, decimal fraction" do
    testcase = %{
      "document" => [
        %{"a" => 1.1, "d" => "e"},
        %{"a" => 1, "d" => "f"},
        %{"a" => "1.1", "d" => "g"}
      ],
      "name" => "filter, equals number, decimal fraction",
      "result" => [%{"a" => 1.1, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==1.1]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals number, decimal fraction, trailing 0" do
    testcase = %{
      "document" => [
        %{"a" => 1.1, "d" => "e"},
        %{"a" => 1, "d" => "f"},
        %{"a" => "1.1", "d" => "g"}
      ],
      "name" => "filter, equals number, decimal fraction, trailing 0",
      "result" => [%{"a" => 1.1, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==1.10]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals number, decimal fraction, exponent" do
    testcase = %{
      "document" => [
        %{"a" => 110, "d" => "e"},
        %{"a" => 110.1, "d" => "f"},
        %{"a" => "110", "d" => "g"}
      ],
      "name" => "filter, equals number, decimal fraction, exponent",
      "result" => [%{"a" => 110, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==1.1e2]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals number, decimal fraction, positive exponent" do
    testcase = %{
      "document" => [
        %{"a" => 110, "d" => "e"},
        %{"a" => 110.1, "d" => "f"},
        %{"a" => "110", "d" => "g"}
      ],
      "name" => "filter, equals number, decimal fraction, positive exponent",
      "result" => [%{"a" => 110, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==1.1e+2]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals number, decimal fraction, negative exponent" do
    testcase = %{
      "document" => [
        %{"a" => 0.011, "d" => "e"},
        %{"a" => 0.012, "d" => "f"},
        %{"a" => "0.011", "d" => "g"}
      ],
      "name" => "filter, equals number, decimal fraction, negative exponent",
      "result" => [%{"a" => 0.011, "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==1.1e-2]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals number, invalid plus" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, equals number, invalid plus",
      "selector" => "$[?@.a==+1]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, equals number, invalid minus space" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, equals number, invalid minus space",
      "selector" => "$[?@.a==- 1]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, equals number, invalid double minus" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, equals number, invalid double minus",
      "selector" => "$[?@.a==--1]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, equals number, invalid no int digit" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, equals number, invalid no int digit",
      "selector" => "$[?@.a==.1]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, equals number, invalid minus no int digit" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, equals number, invalid minus no int digit",
      "selector" => "$[?@.a==-.1]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, equals number, invalid 00" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, equals number, invalid 00",
      "selector" => "$[?@.a==00]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, equals number, invalid leading 0" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, equals number, invalid leading 0",
      "selector" => "$[?@.a==01]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, equals number, invalid no fractional digit" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, equals number, invalid no fractional digit",
      "selector" => "$[?@.a==1.]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, equals number, invalid middle minus" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, equals number, invalid middle minus",
      "selector" => "$[?@.a==1.-1]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, equals number, invalid no fractional digit e" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, equals number, invalid no fractional digit e",
      "selector" => "$[?@.a==1.e1]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, equals number, invalid no e digit" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, equals number, invalid no e digit",
      "selector" => "$[?@.a==1e]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, equals number, invalid no e digit minus" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, equals number, invalid no e digit minus",
      "selector" => "$[?@.a==1e-]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, equals number, invalid double e" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, equals number, invalid double e",
      "selector" => "$[?@.a==1eE1]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, equals number, invalid e digit double minus" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, equals number, invalid e digit double minus",
      "selector" => "$[?@.a==1e--1]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, equals number, invalid e digit plus minus" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, equals number, invalid e digit plus minus",
      "selector" => "$[?@.a==1e+-1]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, equals number, invalid e decimal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, equals number, invalid e decimal",
      "selector" => "$[?@.a==1e2.3]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, equals number, invalid multi e" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, equals number, invalid multi e",
      "selector" => "$[?@.a==1e2e3]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, equals, special nothing" do
    testcase = %{
      "document" => %{"c" => "cd", "values" => [%{"a" => "ab"}, %{"c" => "d"}, %{"a" => nil}]},
      "name" => "filter, equals, special nothing",
      "result" => [%{"c" => "d"}, %{"a" => nil}],
      "result_paths" => ["$['values'][1]", "$['values'][2]"],
      "selector" => "$.values[?length(@.a) == value($..c)]",
      "tags" => ["function"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals, empty node list and empty node list" do
    testcase = %{
      "document" => [%{"a" => 1}, %{"b" => 2}, %{"c" => 3}],
      "name" => "filter, equals, empty node list and empty node list",
      "result" => [%{"c" => 3}],
      "result_paths" => ["$[2]"],
      "selector" => "$[?@.a == @.b]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, equals, empty node list and special nothing" do
    testcase = %{
      "document" => [%{"a" => 1}, %{"b" => 2}, %{"c" => 3}],
      "name" => "filter, equals, empty node list and special nothing",
      "result" => [%{"b" => 2}, %{"c" => 3}],
      "result_paths" => ["$[1]", "$[2]"],
      "selector" => "$[?@.a == length(@.b)]",
      "tags" => ["function", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, object data" do
    testcase = %{
      "document" => %{"a" => 1, "b" => 2, "c" => 3},
      "name" => "filter, object data",
      "results" => [[1, 2], [2, 1]],
      "results_paths" => [["$['a']", "$['b']"], ["$['b']", "$['a']"]],
      "selector" => "$[?@<3]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"results" => results, "results_paths" => results_path} = testcase

    # Multiple results
    {:ok, value} = JSONPath.evaluate(root, selector)
    assert value in results, "no match for query #{selector} and root #{inspect(root)}"
    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)
    assert paths in results_path, "no path match for query #{selector} and root #{inspect(root)}"
  end

  test "filter, two consecutive ands" do
    testcase = %{
      "document" => [
        %{"a" => 1, "b" => 2},
        %{"a" => 1, "c" => 3},
        %{"b" => 2, "c" => 3},
        %{"a" => 1, "b" => 2, "c" => 3}
      ],
      "name" => "filter, two consecutive ands",
      "result" => [%{"a" => 1, "b" => 2, "c" => 3}],
      "result_paths" => ["$[3]"],
      "selector" => "$[?@.a && @.b && @.c]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, two consecutive ors" do
    testcase = %{
      "document" => [
        %{"a" => 1, "b" => 2},
        %{"a" => 1, "c" => 3},
        %{"b" => 2, "c" => 3},
        %{"a" => 1, "b" => 2, "c" => 3}
      ],
      "name" => "filter, two consecutive ors",
      "result" => [
        %{"a" => 1, "b" => 2},
        %{"a" => 1, "c" => 3},
        %{"b" => 2, "c" => 3},
        %{"a" => 1, "b" => 2, "c" => 3}
      ],
      "result_paths" => ["$[0]", "$[1]", "$[2]", "$[3]"],
      "selector" => "$[?@.a || @.b || @.c]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, multiple consecutive ands" do
    testcase = %{
      "document" => [
        %{"a" => 1, "b" => 2, "c" => 3, "d" => 4},
        %{"b" => 2, "c" => 3, "d" => 4, "e" => 5},
        %{"a" => 1, "c" => 3, "e" => 5},
        %{"a" => 1, "b" => 2, "c" => 3, "d" => 4, "e" => 5}
      ],
      "name" => "filter, multiple consecutive ands",
      "result" => [%{"a" => 1, "b" => 2, "c" => 3, "d" => 4, "e" => 5}],
      "result_paths" => ["$[3]"],
      "selector" => "$[?@.a && @.b && @.c && @.d && @.e]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, multiple consecutive ors" do
    testcase = %{
      "document" => [
        %{"a" => 1, "b" => 2, "c" => 3, "d" => 4},
        %{"b" => 2, "c" => 3, "d" => 4, "e" => 5},
        %{"a" => 1, "c" => 3, "e" => 5},
        %{"a" => 1, "b" => 2, "c" => 3, "d" => 4, "e" => 5}
      ],
      "name" => "filter, multiple consecutive ors",
      "result" => [
        %{"a" => 1, "b" => 2, "c" => 3, "d" => 4},
        %{"b" => 2, "c" => 3, "d" => 4, "e" => 5},
        %{"a" => 1, "c" => 3, "e" => 5},
        %{"a" => 1, "b" => 2, "c" => 3, "d" => 4, "e" => 5}
      ],
      "result_paths" => ["$[0]", "$[1]", "$[2]", "$[3]"],
      "selector" => "$[?@.a || @.b || @.c || @.d || @.e]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, multiple consecutive ors and ands" do
    testcase = %{
      "document" => [
        %{"a" => 1},
        %{"e" => 5},
        %{"a" => 1, "b" => 2},
        %{"d" => 4, "e" => 5},
        %{"a" => 1, "b" => 2, "c" => 3},
        %{"c" => 3, "d" => 4, "e" => 5},
        %{"a" => 1, "c" => 3, "e" => 5},
        %{"a" => 1, "b" => 2, "c" => 3, "d" => 4, "e" => 5}
      ],
      "name" => "filter, multiple consecutive ors and ands",
      "result" => [
        %{"e" => 5},
        %{"d" => 4, "e" => 5},
        %{"a" => 1, "b" => 2, "c" => 3},
        %{"c" => 3, "d" => 4, "e" => 5},
        %{"a" => 1, "c" => 3, "e" => 5},
        %{"a" => 1, "b" => 2, "c" => 3, "d" => 4, "e" => 5}
      ],
      "result_paths" => ["$[1]", "$[3]", "$[4]", "$[5]", "$[6]", "$[7]"],
      "selector" => "$[?@.a && @.b && @.c || @.d || @.e]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, and binds more tightly than or" do
    testcase = %{
      "document" => [
        %{"a" => 1},
        %{"b" => 2, "c" => 3},
        %{"c" => 3},
        %{"b" => 2},
        %{"a" => 1, "b" => 2, "c" => 3}
      ],
      "name" => "filter, and binds more tightly than or",
      "result" => [%{"a" => 1}, %{"b" => 2, "c" => 3}, %{"a" => 1, "b" => 2, "c" => 3}],
      "result_paths" => ["$[0]", "$[1]", "$[4]"],
      "selector" => "$[?@.a || @.b && @.c]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, left to right evaluation" do
    testcase = %{
      "document" => [
        %{"a" => 1},
        %{"b" => 2},
        %{"a" => 1, "b" => 2},
        %{"a" => 1, "c" => 3},
        %{"b" => 1, "c" => 3},
        %{"c" => 3},
        %{"a" => 1, "b" => 2, "c" => 3}
      ],
      "name" => "filter, left to right evaluation",
      "result" => [
        %{"a" => 1, "b" => 2},
        %{"a" => 1, "c" => 3},
        %{"b" => 1, "c" => 3},
        %{"c" => 3},
        %{"a" => 1, "b" => 2, "c" => 3}
      ],
      "result_paths" => ["$[2]", "$[3]", "$[4]", "$[5]", "$[6]"],
      "selector" => "$[?@.a && @.b || @.c]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, group terms, left" do
    testcase = %{
      "document" => [
        %{"a" => 1, "b" => 2},
        %{"a" => 1, "c" => 3},
        %{"b" => 2, "c" => 3},
        %{"a" => 1},
        %{"b" => 2},
        %{"c" => 3},
        %{"a" => 1, "b" => 2, "c" => 3}
      ],
      "name" => "filter, group terms, left",
      "result" => [%{"a" => 1, "c" => 3}, %{"b" => 2, "c" => 3}, %{"a" => 1, "b" => 2, "c" => 3}],
      "result_paths" => ["$[1]", "$[2]", "$[6]"],
      "selector" => "$[?(@.a || @.b) && @.c]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, group terms, right" do
    testcase = %{
      "document" => [
        %{"a" => 1},
        %{"a" => 1, "b" => 2},
        %{"a" => 1, "c" => 2},
        %{"b" => 2},
        %{"c" => 2},
        %{"a" => 1, "b" => 2, "c" => 3}
      ],
      "name" => "filter, group terms, right",
      "result" => [%{"a" => 1, "b" => 2}, %{"a" => 1, "c" => 2}, %{"a" => 1, "b" => 2, "c" => 3}],
      "result_paths" => ["$[1]", "$[2]", "$[5]"],
      "selector" => "$[?@.a && (@.b || @.c)]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, string literal, single quote in double quotes" do
    testcase = %{
      "document" => ["quoted' literal", "a", "quoted\\' literal"],
      "name" => "filter, string literal, single quote in double quotes",
      "result" => ["quoted' literal"],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@ == \"quoted' literal\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, string literal, double quote in single quotes" do
    testcase = %{
      "document" => ["quoted\" literal", "a", "quoted\\\" literal", "'quoted\" literal'"],
      "name" => "filter, string literal, double quote in single quotes",
      "result" => ["quoted\" literal"],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@ == 'quoted\" literal']",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, string literal, escaped single quote in single quotes" do
    testcase = %{
      "document" => ["quoted' literal", "a", "quoted\\' literal", "'quoted\" literal'"],
      "name" => "filter, string literal, escaped single quote in single quotes",
      "result" => ["quoted' literal"],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@ == 'quoted\\' literal']",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, string literal, escaped double quote in double quotes" do
    testcase = %{
      "document" => ["quoted\" literal", "a", "quoted\\\" literal", "'quoted\" literal'"],
      "name" => "filter, string literal, escaped double quote in double quotes",
      "result" => ["quoted\" literal"],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@ == \"quoted\\\" literal\"]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, literal true must be compared" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, literal true must be compared",
      "selector" => "$[?true]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, literal false must be compared" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, literal false must be compared",
      "selector" => "$[?false]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, literal string must be compared" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, literal string must be compared",
      "selector" => "$[?'abc']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, literal int must be compared" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, literal int must be compared",
      "selector" => "$[?2]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, literal float must be compared" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, literal float must be compared",
      "selector" => "$[?2.2]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, literal null must be compared" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, literal null must be compared",
      "selector" => "$[?null]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, and, literals must be compared" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, and, literals must be compared",
      "selector" => "$[?true && false]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, or, literals must be compared" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, or, literals must be compared",
      "selector" => "$[?true || false]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, and, right hand literal must be compared" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, and, right hand literal must be compared",
      "selector" => "$[?true == false && false]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, or, right hand literal must be compared" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, or, right hand literal must be compared",
      "selector" => "$[?true == false || false]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, and, left hand literal must be compared" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, and, left hand literal must be compared",
      "selector" => "$[?false && true == false]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, or, left hand literal must be compared" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, or, left hand literal must be compared",
      "selector" => "$[?false || true == false]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, true, incorrectly capitalized" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, true, incorrectly capitalized",
      "selector" => "$[?@==True]",
      "tags" => ["case"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, quoted True, double quotes" do
    testcase = %{
      "document" => [%{"a" => "True"}, %{"a" => true}, %{"a" => "SomethingElse"}],
      "name" => "filter, quoted True, double quotes",
      "result" => [%{"a" => "True"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==\"True\"]",
      "tags" => ["case"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, quoted True, single quotes" do
    testcase = %{
      "document" => [%{"a" => "True"}, %{"a" => true}, %{"a" => "SomethingElse"}],
      "name" => "filter, quoted True, single quotes",
      "result" => [%{"a" => "True"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a=='True']",
      "tags" => ["case"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, false, incorrectly capitalized" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, false, incorrectly capitalized",
      "selector" => "$[?@==False]",
      "tags" => ["case"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, quoted False, double quotes" do
    testcase = %{
      "document" => [%{"a" => "False"}, %{"a" => false}, %{"a" => "SomethingElse"}],
      "name" => "filter, quoted False, double quotes",
      "result" => [%{"a" => "False"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==\"False\"]",
      "tags" => ["case"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, quoted False, single quotes" do
    testcase = %{
      "document" => [%{"a" => "False"}, %{"a" => false}, %{"a" => "SomethingElse"}],
      "name" => "filter, quoted False, single quotes",
      "result" => [%{"a" => "False"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a=='False']",
      "tags" => ["case"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, null, incorrectly capitalized" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "filter, null, incorrectly capitalized",
      "selector" => "$[?@==Null]",
      "tags" => ["case"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "filter, quoted Null, double quotes" do
    testcase = %{
      "document" => [%{"a" => "Null"}, %{"a" => nil}, %{"a" => "SomethingElse"}],
      "name" => "filter, quoted Null, double quotes",
      "result" => [%{"a" => "Null"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==\"Null\"]",
      "tags" => ["case"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "filter, quoted Null, single quotes" do
    testcase = %{
      "document" => [%{"a" => "Null"}, %{"a" => nil}, %{"a" => "SomethingElse"}],
      "name" => "filter, quoted Null, single quotes",
      "result" => [%{"a" => "Null"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a=='Null']",
      "tags" => ["case"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "index selector, first element" do
    testcase = %{
      "document" => ["first", "second"],
      "name" => "index selector, first element",
      "result" => ["first"],
      "result_paths" => ["$[0]"],
      "selector" => "$[0]",
      "tags" => ["index"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "index selector, second element" do
    testcase = %{
      "document" => ["first", "second"],
      "name" => "index selector, second element",
      "result" => ["second"],
      "result_paths" => ["$[1]"],
      "selector" => "$[1]",
      "tags" => ["index"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "index selector, out of bound" do
    testcase = %{
      "document" => ["first", "second"],
      "name" => "index selector, out of bound",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[2]",
      "tags" => ["boundary", "index"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "index selector, min exact index" do
    testcase = %{
      "document" => ["first", "second"],
      "name" => "index selector, min exact index",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[-9007199254740991]",
      "tags" => ["boundary", "index"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "index selector, max exact index" do
    testcase = %{
      "document" => ["first", "second"],
      "name" => "index selector, max exact index",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[9007199254740991]",
      "tags" => ["boundary", "index"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "index selector, min exact index - 1" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "index selector, min exact index - 1",
      "selector" => "$[-9007199254740992]",
      "tags" => ["boundary", "index"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "index selector, max exact index + 1" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "index selector, max exact index + 1",
      "selector" => "$[9007199254740992]",
      "tags" => ["boundary", "index"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "index selector, overflowing index" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "index selector, overflowing index",
      "selector" =>
        "$[231584178474632390847141970017375815706539969331281128078915168015826259279872]",
      "tags" => ["boundary", "index"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "index selector, not actually an index, overflowing index leads into general text" do
    testcase = %{
      "invalid_selector" => true,
      "name" =>
        "index selector, not actually an index, overflowing index leads into general text",
      "selector" =>
        "$[231584178474632390847141970017375815706539969331281128078915168SomeRandomText]",
      "tags" => ["index"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "index selector, negative" do
    testcase = %{
      "document" => ["first", "second"],
      "name" => "index selector, negative",
      "result" => ["second"],
      "result_paths" => ["$[1]"],
      "selector" => "$[-1]",
      "tags" => ["index"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "index selector, more negative" do
    testcase = %{
      "document" => ["first", "second"],
      "name" => "index selector, more negative",
      "result" => ["first"],
      "result_paths" => ["$[0]"],
      "selector" => "$[-2]",
      "tags" => ["index"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "index selector, negative out of bound" do
    testcase = %{
      "document" => ["first", "second"],
      "name" => "index selector, negative out of bound",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[-3]",
      "tags" => ["boundary", "index"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "index selector, on object" do
    testcase = %{
      "document" => %{"foo" => 1},
      "name" => "index selector, on object",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[0]",
      "tags" => ["index"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "index selector, leading 0" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "index selector, leading 0",
      "selector" => "$[01]",
      "tags" => ["index"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "index selector, decimal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "index selector, decimal",
      "selector" => "$[1.0]",
      "tags" => ["index"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "index selector, plus" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "index selector, plus",
      "selector" => "$[+1]",
      "tags" => ["index"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "index selector, minus space" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "index selector, minus space",
      "selector" => "$[- 1]",
      "tags" => ["index", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "index selector, -0" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "index selector, -0",
      "selector" => "$[-0]",
      "tags" => ["index"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "index selector, leading -0" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "index selector, leading -0",
      "selector" => "$[-01]",
      "tags" => ["index"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes" do
    testcase = %{
      "document" => %{"a" => "A", "b" => "B"},
      "name" => "name selector, double quotes",
      "result" => ["A"],
      "result_paths" => ["$['a']"],
      "selector" => "$[\"a\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, double quotes, absent data" do
    testcase = %{
      "document" => %{"a" => "A", "b" => "B"},
      "name" => "name selector, double quotes, absent data",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[\"c\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, double quotes, array data" do
    testcase = %{
      "document" => ["first", "second"],
      "name" => "name selector, double quotes, array data",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[\"a\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, name, double quotes, contains single quote" do
    testcase = %{
      "document" => %{"a'" => "A", "b" => "B"},
      "name" => "name selector, name, double quotes, contains single quote",
      "result" => ["A"],
      "result_paths" => ["$['a\\'']"],
      "selector" => "$[\"a'\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, name, double quotes, nested" do
    testcase = %{
      "document" => %{"a" => %{"b" => %{"c" => "C"}}},
      "name" => "name selector, name, double quotes, nested",
      "result" => ["C"],
      "result_paths" => ["$['a']['b']['c']"],
      "selector" => "$[\"a\"][\"b\"][\"c\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, double quotes, embedded U+0000" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+0000",
      "selector" => <<36, 91, 34, 0, 34, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+0001" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+0001",
      "selector" => <<36, 91, 34, 1, 34, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+0002" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+0002",
      "selector" => <<36, 91, 34, 2, 34, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+0003" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+0003",
      "selector" => <<36, 91, 34, 3, 34, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+0004" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+0004",
      "selector" => <<36, 91, 34, 4, 34, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+0005" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+0005",
      "selector" => <<36, 91, 34, 5, 34, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+0006" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+0006",
      "selector" => <<36, 91, 34, 6, 34, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+0007" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+0007",
      "selector" => "$[\"\a\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+0008" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+0008",
      "selector" => "$[\"\b\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+0009" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+0009",
      "selector" => "$[\"\t\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+000A" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+000A",
      "selector" => "$[\"\n\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+000B" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+000B",
      "selector" => "$[\"\v\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+000C" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+000C",
      "selector" => "$[\"\f\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+000D" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+000D",
      "selector" => "$[\"\r\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+000E" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+000E",
      "selector" => <<36, 91, 34, 14, 34, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+000F" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+000F",
      "selector" => <<36, 91, 34, 15, 34, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+0010" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+0010",
      "selector" => <<36, 91, 34, 16, 34, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+0011" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+0011",
      "selector" => <<36, 91, 34, 17, 34, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+0012" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+0012",
      "selector" => <<36, 91, 34, 18, 34, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+0013" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+0013",
      "selector" => <<36, 91, 34, 19, 34, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+0014" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+0014",
      "selector" => <<36, 91, 34, 20, 34, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+0015" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+0015",
      "selector" => <<36, 91, 34, 21, 34, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+0016" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+0016",
      "selector" => <<36, 91, 34, 22, 34, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+0017" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+0017",
      "selector" => <<36, 91, 34, 23, 34, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+0018" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+0018",
      "selector" => <<36, 91, 34, 24, 34, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+0019" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+0019",
      "selector" => <<36, 91, 34, 25, 34, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+001A" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+001A",
      "selector" => <<36, 91, 34, 26, 34, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+001B" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+001B",
      "selector" => "$[\"\e\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+001C" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+001C",
      "selector" => <<36, 91, 34, 28, 34, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+001D" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+001D",
      "selector" => <<36, 91, 34, 29, 34, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+001E" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+001E",
      "selector" => <<36, 91, 34, 30, 34, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+001F" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded U+001F",
      "selector" => <<36, 91, 34, 31, 34, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded U+0020" do
    testcase = %{
      "document" => %{" " => "A"},
      "name" => "name selector, double quotes, embedded U+0020",
      "result" => ["A"],
      "result_paths" => ["$[' ']"],
      "selector" => "$[\" \"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, double quotes, embedded U+007F" do
    testcase = %{
      "document" => %{"\d" => "A"},
      "name" => "name selector, double quotes, embedded U+007F",
      "result" => ["A"],
      "result_paths" => ["$['\d']"],
      "selector" => "$[\"\d\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, double quotes, supplementary plane character" do
    testcase = %{
      "document" => %{"𝄞" => "A"},
      "name" => "name selector, double quotes, supplementary plane character",
      "result" => ["A"],
      "result_paths" => ["$['𝄞']"],
      "selector" => "$[\"𝄞\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, double quotes, escaped double quote" do
    testcase = %{
      "document" => %{"\"" => "A"},
      "name" => "name selector, double quotes, escaped double quote",
      "result" => ["A"],
      "result_paths" => ["$['\"']"],
      "selector" => "$[\"\\\"\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, double quotes, escaped reverse solidus" do
    testcase = %{
      "document" => %{"\\" => "A"},
      "name" => "name selector, double quotes, escaped reverse solidus",
      "result" => ["A"],
      "result_paths" => ["$['\\\\']"],
      "selector" => "$[\"\\\\\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, double quotes, escaped solidus" do
    testcase = %{
      "document" => %{"/" => "A"},
      "name" => "name selector, double quotes, escaped solidus",
      "result" => ["A"],
      "result_paths" => ["$['/']"],
      "selector" => "$[\"\\/\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, double quotes, escaped backspace" do
    testcase = %{
      "document" => %{"\b" => "A"},
      "name" => "name selector, double quotes, escaped backspace",
      "result" => ["A"],
      "result_paths" => ["$['\\b']"],
      "selector" => "$[\"\\b\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, double quotes, escaped form feed" do
    testcase = %{
      "document" => %{"\f" => "A"},
      "name" => "name selector, double quotes, escaped form feed",
      "result" => ["A"],
      "result_paths" => ["$['\\f']"],
      "selector" => "$[\"\\f\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, double quotes, escaped line feed" do
    testcase = %{
      "document" => %{"\n" => "A"},
      "name" => "name selector, double quotes, escaped line feed",
      "result" => ["A"],
      "result_paths" => ["$['\\n']"],
      "selector" => "$[\"\\n\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, double quotes, escaped carriage return" do
    testcase = %{
      "document" => %{"\r" => "A"},
      "name" => "name selector, double quotes, escaped carriage return",
      "result" => ["A"],
      "result_paths" => ["$['\\r']"],
      "selector" => "$[\"\\r\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, double quotes, escaped tab" do
    testcase = %{
      "document" => %{"\t" => "A"},
      "name" => "name selector, double quotes, escaped tab",
      "result" => ["A"],
      "result_paths" => ["$['\\t']"],
      "selector" => "$[\"\\t\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, double quotes, escaped ☺, upper case hex" do
    testcase = %{
      "document" => %{"☺" => "A"},
      "name" => "name selector, double quotes, escaped ☺, upper case hex",
      "result" => ["A"],
      "result_paths" => ["$['☺']"],
      "selector" => "$[\"\\u263A\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, double quotes, escaped ☺, lower case hex" do
    testcase = %{
      "document" => %{"☺" => "A"},
      "name" => "name selector, double quotes, escaped ☺, lower case hex",
      "result" => ["A"],
      "result_paths" => ["$['☺']"],
      "selector" => "$[\"\\u263a\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, double quotes, surrogate pair 𝄞" do
    testcase = %{
      "document" => %{"𝄞" => "A"},
      "name" => "name selector, double quotes, surrogate pair 𝄞",
      "result" => ["A"],
      "result_paths" => ["$['𝄞']"],
      "selector" => "$[\"\\uD834\\uDD1E\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, double quotes, surrogate pair 😀" do
    testcase = %{
      "document" => %{"😀" => "A"},
      "name" => "name selector, double quotes, surrogate pair 😀",
      "result" => ["A"],
      "result_paths" => ["$['😀']"],
      "selector" => "$[\"\\uD83D\\uDE00\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, double quotes, before high surrogates" do
    testcase = %{
      "document" => %{"퟿퟿" => "A"},
      "name" => "name selector, double quotes, before high surrogates",
      "result" => ["A"],
      "result_paths" => ["$['퟿퟿']"],
      "selector" => "$[\"\\uD7FF\\uD7FF\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, double quotes, after low surrogates" do
    testcase = %{
      "document" => %{"" => "A"},
      "name" => "name selector, double quotes, after low surrogates",
      "result" => ["A"],
      "result_paths" => ["$['']"],
      "selector" => "$[\"\\uE000\\uE000\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, double quotes, invalid escaped single quote" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, invalid escaped single quote",
      "selector" => "$[\"\\'\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, embedded double quote" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, embedded double quote",
      "selector" => "$[\"\"\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, incomplete escape" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, incomplete escape",
      "selector" => "$[\"\\\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, escape at end of line" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, escape at end of line",
      "selector" => "$[\"\\\n\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, question mark escape" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, question mark escape",
      "selector" => "$[\"\\?\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, bell escape" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, bell escape",
      "selector" => "$[\"\\a\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, vertical tab escape" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, vertical tab escape",
      "selector" => "$[\"\\v\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, 0 escape" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, 0 escape",
      "selector" => "$[\"\\0\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, x escape" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, x escape",
      "selector" => "$[\"\\x12\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, n escape" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, n escape",
      "selector" => "$[\"\\N{LATIN CAPITAL LETTER A}\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, unicode escape no hex" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, unicode escape no hex",
      "selector" => "$[\"\\u\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, unicode escape too few hex" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, unicode escape too few hex",
      "selector" => "$[\"\\u123\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, unicode escape upper u" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, unicode escape upper u",
      "selector" => "$[\"\\U1234\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, unicode escape upper u long" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, unicode escape upper u long",
      "selector" => "$[\"\\U0010FFFF\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, unicode escape plus" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, unicode escape plus",
      "selector" => "$[\"\\u+1234\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, unicode escape brackets" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, unicode escape brackets",
      "selector" => "$[\"\\u{1234}\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, unicode escape brackets long" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, unicode escape brackets long",
      "selector" => "$[\"\\u{10ffff}\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, single high surrogate" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, single high surrogate",
      "selector" => "$[\"\\uD800\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, single low surrogate" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, single low surrogate",
      "selector" => "$[\"\\uDC00\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, high high surrogate" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, high high surrogate",
      "selector" => "$[\"\\uD800\\uD800\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, low low surrogate" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, low low surrogate",
      "selector" => "$[\"\\uDC00\\uDC00\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, surrogate non-surrogate" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, surrogate non-surrogate",
      "selector" => "$[\"\\uD800\\u1234\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, non-surrogate surrogate" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, non-surrogate surrogate",
      "selector" => "$[\"\\u1234\\uDC00\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, surrogate supplementary" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, surrogate supplementary",
      "selector" => "$[\"\\uD800𝄞\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, supplementary surrogate" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, supplementary surrogate",
      "selector" => "$[\"𝄞\\uDC00\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, surrogate incomplete low" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, double quotes, surrogate incomplete low",
      "selector" => "$[\"\\uD800\\uDC0\"]",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes" do
    testcase = %{
      "document" => %{"a" => "A", "b" => "B"},
      "name" => "name selector, single quotes",
      "result" => ["A"],
      "result_paths" => ["$['a']"],
      "selector" => "$['a']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, single quotes, absent data" do
    testcase = %{
      "document" => %{"a" => "A", "b" => "B"},
      "name" => "name selector, single quotes, absent data",
      "result" => [],
      "result_paths" => [],
      "selector" => "$['c']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, single quotes, array data" do
    testcase = %{
      "document" => ["first", "second"],
      "name" => "name selector, single quotes, array data",
      "result" => [],
      "result_paths" => [],
      "selector" => "$['a']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, single quotes, embedded U+0000" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+0000",
      "selector" => <<36, 91, 39, 0, 39, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+0001" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+0001",
      "selector" => <<36, 91, 39, 1, 39, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+0002" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+0002",
      "selector" => <<36, 91, 39, 2, 39, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+0003" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+0003",
      "selector" => <<36, 91, 39, 3, 39, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+0004" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+0004",
      "selector" => <<36, 91, 39, 4, 39, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+0005" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+0005",
      "selector" => <<36, 91, 39, 5, 39, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+0006" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+0006",
      "selector" => <<36, 91, 39, 6, 39, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+0007" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+0007",
      "selector" => "$['\a']",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+0008" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+0008",
      "selector" => "$['\b']",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+0009" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+0009",
      "selector" => "$['\t']",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+000A" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+000A",
      "selector" => "$['\n']",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+000B" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+000B",
      "selector" => "$['\v']",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+000C" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+000C",
      "selector" => "$['\f']",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+000D" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+000D",
      "selector" => "$['\r']",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+000E" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+000E",
      "selector" => <<36, 91, 39, 14, 39, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+000F" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+000F",
      "selector" => <<36, 91, 39, 15, 39, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+0010" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+0010",
      "selector" => <<36, 91, 39, 16, 39, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+0011" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+0011",
      "selector" => <<36, 91, 39, 17, 39, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+0012" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+0012",
      "selector" => <<36, 91, 39, 18, 39, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+0013" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+0013",
      "selector" => <<36, 91, 39, 19, 39, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+0014" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+0014",
      "selector" => <<36, 91, 39, 20, 39, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+0015" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+0015",
      "selector" => <<36, 91, 39, 21, 39, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+0016" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+0016",
      "selector" => <<36, 91, 39, 22, 39, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+0017" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+0017",
      "selector" => <<36, 91, 39, 23, 39, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+0018" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+0018",
      "selector" => <<36, 91, 39, 24, 39, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+0019" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+0019",
      "selector" => <<36, 91, 39, 25, 39, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+001A" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+001A",
      "selector" => <<36, 91, 39, 26, 39, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+001B" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+001B",
      "selector" => "$['\e']",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+001C" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+001C",
      "selector" => <<36, 91, 39, 28, 39, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+001D" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+001D",
      "selector" => <<36, 91, 39, 29, 39, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+001E" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+001E",
      "selector" => <<36, 91, 39, 30, 39, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+001F" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded U+001F",
      "selector" => <<36, 91, 39, 31, 39, 93>>,
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded U+0020" do
    testcase = %{
      "document" => %{" " => "A"},
      "name" => "name selector, single quotes, embedded U+0020",
      "result" => ["A"],
      "result_paths" => ["$[' ']"],
      "selector" => "$[' ']",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, single quotes, escaped single quote" do
    testcase = %{
      "document" => %{"'" => "A"},
      "name" => "name selector, single quotes, escaped single quote",
      "result" => ["A"],
      "result_paths" => ["$['\\'']"],
      "selector" => "$['\\'']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, single quotes, escaped reverse solidus" do
    testcase = %{
      "document" => %{"\\" => "A"},
      "name" => "name selector, single quotes, escaped reverse solidus",
      "result" => ["A"],
      "result_paths" => ["$['\\\\']"],
      "selector" => "$['\\\\']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, single quotes, escaped solidus" do
    testcase = %{
      "document" => %{"/" => "A"},
      "name" => "name selector, single quotes, escaped solidus",
      "result" => ["A"],
      "result_paths" => ["$['/']"],
      "selector" => "$['\\/']",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, single quotes, escaped backspace" do
    testcase = %{
      "document" => %{"\b" => "A"},
      "name" => "name selector, single quotes, escaped backspace",
      "result" => ["A"],
      "result_paths" => ["$['\\b']"],
      "selector" => "$['\\b']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, single quotes, escaped form feed" do
    testcase = %{
      "document" => %{"\f" => "A"},
      "name" => "name selector, single quotes, escaped form feed",
      "result" => ["A"],
      "result_paths" => ["$['\\f']"],
      "selector" => "$['\\f']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, single quotes, escaped line feed" do
    testcase = %{
      "document" => %{"\n" => "A"},
      "name" => "name selector, single quotes, escaped line feed",
      "result" => ["A"],
      "result_paths" => ["$['\\n']"],
      "selector" => "$['\\n']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, single quotes, escaped carriage return" do
    testcase = %{
      "document" => %{"\r" => "A"},
      "name" => "name selector, single quotes, escaped carriage return",
      "result" => ["A"],
      "result_paths" => ["$['\\r']"],
      "selector" => "$['\\r']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, single quotes, escaped tab" do
    testcase = %{
      "document" => %{"\t" => "A"},
      "name" => "name selector, single quotes, escaped tab",
      "result" => ["A"],
      "result_paths" => ["$['\\t']"],
      "selector" => "$['\\t']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, single quotes, escaped ☺, upper case hex" do
    testcase = %{
      "document" => %{"☺" => "A"},
      "name" => "name selector, single quotes, escaped ☺, upper case hex",
      "result" => ["A"],
      "result_paths" => ["$['☺']"],
      "selector" => "$['\\u263A']",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, single quotes, escaped ☺, lower case hex" do
    testcase = %{
      "document" => %{"☺" => "A"},
      "name" => "name selector, single quotes, escaped ☺, lower case hex",
      "result" => ["A"],
      "result_paths" => ["$['☺']"],
      "selector" => "$['\\u263a']",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, single quotes, surrogate pair 𝄞" do
    testcase = %{
      "document" => %{"𝄞" => "A"},
      "name" => "name selector, single quotes, surrogate pair 𝄞",
      "result" => ["A"],
      "result_paths" => ["$['𝄞']"],
      "selector" => "$['\\uD834\\uDD1E']",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, single quotes, surrogate pair 😀" do
    testcase = %{
      "document" => %{"😀" => "A"},
      "name" => "name selector, single quotes, surrogate pair 😀",
      "result" => ["A"],
      "result_paths" => ["$['😀']"],
      "selector" => "$['\\uD83D\\uDE00']",
      "tags" => ["unicode"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, single quotes, invalid escaped double quote" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, invalid escaped double quote",
      "selector" => "$['\\\"']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, embedded single quote" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, embedded single quote",
      "selector" => "$[''']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, single quotes, incomplete escape" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "name selector, single quotes, incomplete escape",
      "selector" => "$['\\']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "name selector, double quotes, empty" do
    testcase = %{
      "document" => %{"" => "C", "a" => "A", "b" => "B"},
      "name" => "name selector, double quotes, empty",
      "result" => ["C"],
      "result_paths" => ["$['']"],
      "selector" => "$[\"\"]"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "name selector, single quotes, empty" do
    testcase = %{
      "document" => %{"" => "C", "a" => "A", "b" => "B"},
      "name" => "name selector, single quotes, empty",
      "result" => ["C"],
      "result_paths" => ["$['']"],
      "selector" => "$['']"
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, slice selector" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "slice selector, slice selector",
      "result" => [1, 2],
      "result_paths" => ["$[1]", "$[2]"],
      "selector" => "$[1:3]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, slice selector with step" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "slice selector, slice selector with step",
      "result" => [1, 3, 5],
      "result_paths" => ["$[1]", "$[3]", "$[5]"],
      "selector" => "$[1:6:2]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, slice selector with everything omitted, short form" do
    testcase = %{
      "document" => [0, 1, 2, 3],
      "name" => "slice selector, slice selector with everything omitted, short form",
      "result" => [0, 1, 2, 3],
      "result_paths" => ["$[0]", "$[1]", "$[2]", "$[3]"],
      "selector" => "$[:]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, slice selector with everything omitted, long form" do
    testcase = %{
      "document" => [0, 1, 2, 3],
      "name" => "slice selector, slice selector with everything omitted, long form",
      "result" => [0, 1, 2, 3],
      "result_paths" => ["$[0]", "$[1]", "$[2]", "$[3]"],
      "selector" => "$[::]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, slice selector with start omitted" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "slice selector, slice selector with start omitted",
      "result" => [0, 1],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[:2]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, slice selector with start and end omitted" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "slice selector, slice selector with start and end omitted",
      "result" => [0, 2, 4, 6, 8],
      "result_paths" => ["$[0]", "$[2]", "$[4]", "$[6]", "$[8]"],
      "selector" => "$[::2]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, negative step with default start and end" do
    testcase = %{
      "document" => [0, 1, 2, 3],
      "name" => "slice selector, negative step with default start and end",
      "result" => [3, 2, 1, 0],
      "result_paths" => ["$[3]", "$[2]", "$[1]", "$[0]"],
      "selector" => "$[::-1]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, negative step with default start" do
    testcase = %{
      "document" => [0, 1, 2, 3],
      "name" => "slice selector, negative step with default start",
      "result" => [3, 2, 1],
      "result_paths" => ["$[3]", "$[2]", "$[1]"],
      "selector" => "$[:0:-1]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, negative step with default end" do
    testcase = %{
      "document" => [0, 1, 2, 3],
      "name" => "slice selector, negative step with default end",
      "result" => [2, 1, 0],
      "result_paths" => ["$[2]", "$[1]", "$[0]"],
      "selector" => "$[2::-1]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, larger negative step" do
    testcase = %{
      "document" => [0, 1, 2, 3],
      "name" => "slice selector, larger negative step",
      "result" => [3, 1],
      "result_paths" => ["$[3]", "$[1]"],
      "selector" => "$[::-2]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, negative range with default step" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "slice selector, negative range with default step",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[-1:-3]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, negative range with negative step" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "slice selector, negative range with negative step",
      "result" => ~c"\t\b",
      "result_paths" => ["$[9]", "$[8]"],
      "selector" => "$[-1:-3:-1]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, negative range with larger negative step" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "slice selector, negative range with larger negative step",
      "result" => [9, 7, 5],
      "result_paths" => ["$[9]", "$[7]", "$[5]"],
      "selector" => "$[-1:-6:-2]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, larger negative range with larger negative step" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "slice selector, larger negative range with larger negative step",
      "result" => [9, 7, 5],
      "result_paths" => ["$[9]", "$[7]", "$[5]"],
      "selector" => "$[-1:-7:-2]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, negative from, positive to" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "slice selector, negative from, positive to",
      "result" => [5, 6],
      "result_paths" => ["$[5]", "$[6]"],
      "selector" => "$[-5:7]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, negative from" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "slice selector, negative from",
      "result" => ~c"\b\t",
      "result_paths" => ["$[8]", "$[9]"],
      "selector" => "$[-2:]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, positive from, negative to" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "slice selector, positive from, negative to",
      "result" => [1, 2, 3, 4, 5, 6, 7, 8],
      "result_paths" => ["$[1]", "$[2]", "$[3]", "$[4]", "$[5]", "$[6]", "$[7]", "$[8]"],
      "selector" => "$[1:-1]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, negative from, positive to, negative step" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "slice selector, negative from, positive to, negative step",
      "result" => [9, 8, 7, 6, 5, 4, 3, 2],
      "result_paths" => ["$[9]", "$[8]", "$[7]", "$[6]", "$[5]", "$[4]", "$[3]", "$[2]"],
      "selector" => "$[-1:1:-1]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, positive from, negative to, negative step" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "slice selector, positive from, negative to, negative step",
      "result" => [7, 6],
      "result_paths" => ["$[7]", "$[6]"],
      "selector" => "$[7:-5:-1]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, in serial, on nested array" do
    testcase = %{
      "document" => [["a", "b", "c"], ["d", "e", "f"], ["g", "h", "i"]],
      "name" => "slice selector, in serial, on nested array",
      "result" => ["e", "h"],
      "result_paths" => ["$[1][1]", "$[2][1]"],
      "selector" => "$[1:3][1:2]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, in serial, on flat array" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5],
      "name" => "slice selector, in serial, on flat array",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[1:3][::]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, negative from, negative to, positive step" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "slice selector, negative from, negative to, positive step",
      "result" => [5, 6, 7],
      "result_paths" => ["$[5]", "$[6]", "$[7]"],
      "selector" => "$[-5:-2]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, too many colons" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, too many colons",
      "selector" => "$[1:2:3:4]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, non-integer array index" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, non-integer array index",
      "selector" => "$[1:2:a]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, zero step" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "slice selector, zero step",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[1:2:0]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, empty range" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "slice selector, empty range",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[2:2]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, slice selector with everything omitted with empty array" do
    testcase = %{
      "document" => [],
      "name" => "slice selector, slice selector with everything omitted with empty array",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[:]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, negative step with empty array" do
    testcase = %{
      "document" => [],
      "name" => "slice selector, negative step with empty array",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[::-1]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, maximal range with positive step" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "slice selector, maximal range with positive step",
      "result" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "result_paths" => [
        "$[0]",
        "$[1]",
        "$[2]",
        "$[3]",
        "$[4]",
        "$[5]",
        "$[6]",
        "$[7]",
        "$[8]",
        "$[9]"
      ],
      "selector" => "$[0:10]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, maximal range with negative step" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "slice selector, maximal range with negative step",
      "result" => [9, 8, 7, 6, 5, 4, 3, 2, 1],
      "result_paths" => ["$[9]", "$[8]", "$[7]", "$[6]", "$[5]", "$[4]", "$[3]", "$[2]", "$[1]"],
      "selector" => "$[9:0:-1]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, excessively large to value" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "slice selector, excessively large to value",
      "result" => [2, 3, 4, 5, 6, 7, 8, 9],
      "result_paths" => ["$[2]", "$[3]", "$[4]", "$[5]", "$[6]", "$[7]", "$[8]", "$[9]"],
      "selector" => "$[2:113667776004]",
      "tags" => ["boundary", "slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, excessively small from value" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "slice selector, excessively small from value",
      "result" => [0],
      "result_paths" => ["$[0]"],
      "selector" => "$[-113667776004:1]",
      "tags" => ["boundary", "slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, excessively large from value with negative step" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "slice selector, excessively large from value with negative step",
      "result" => [9, 8, 7, 6, 5, 4, 3, 2, 1],
      "result_paths" => ["$[9]", "$[8]", "$[7]", "$[6]", "$[5]", "$[4]", "$[3]", "$[2]", "$[1]"],
      "selector" => "$[113667776004:0:-1]",
      "tags" => ["boundary", "slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, excessively small to value with negative step" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "slice selector, excessively small to value with negative step",
      "result" => [3, 2, 1, 0],
      "result_paths" => ["$[3]", "$[2]", "$[1]", "$[0]"],
      "selector" => "$[3:-113667776004:-1]",
      "tags" => ["boundary", "slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, excessively large step" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "slice selector, excessively large step",
      "result" => [1],
      "result_paths" => ["$[1]"],
      "selector" => "$[1:10:113667776004]",
      "tags" => ["boundary", "slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, excessively small step" do
    testcase = %{
      "document" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "name" => "slice selector, excessively small step",
      "result" => ~c"\t",
      "result_paths" => ["$[9]"],
      "selector" => "$[-1:-10:-113667776004]",
      "tags" => ["boundary", "slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, start, min exact" do
    testcase = %{
      "document" => [],
      "name" => "slice selector, start, min exact",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[-9007199254740991::]",
      "tags" => ["boundary", "slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, start, max exact" do
    testcase = %{
      "document" => [],
      "name" => "slice selector, start, max exact",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[9007199254740991::]",
      "tags" => ["boundary", "slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, start, min exact - 1" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, start, min exact - 1",
      "selector" => "$[-9007199254740992::]",
      "tags" => ["boundary", "slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, start, max exact + 1" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, start, max exact + 1",
      "selector" => "$[9007199254740992::]",
      "tags" => ["boundary", "slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, end, min exact" do
    testcase = %{
      "document" => [],
      "name" => "slice selector, end, min exact",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[:-9007199254740991:]",
      "tags" => ["boundary", "slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, end, max exact" do
    testcase = %{
      "document" => [],
      "name" => "slice selector, end, max exact",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[:9007199254740991:]",
      "tags" => ["boundary", "slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, end, min exact - 1" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, end, min exact - 1",
      "selector" => "$[:-9007199254740992:]",
      "tags" => ["boundary", "slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, end, max exact + 1" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, end, max exact + 1",
      "selector" => "$[:9007199254740992:]",
      "tags" => ["boundary", "slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, step, min exact" do
    testcase = %{
      "document" => [],
      "name" => "slice selector, step, min exact",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[::-9007199254740991]",
      "tags" => ["boundary", "slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, step, max exact" do
    testcase = %{
      "document" => [],
      "name" => "slice selector, step, max exact",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[::9007199254740991]",
      "tags" => ["boundary", "slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "slice selector, step, min exact - 1" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, step, min exact - 1",
      "selector" => "$[::-9007199254740992]",
      "tags" => ["boundary", "slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, step, max exact + 1" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, step, max exact + 1",
      "selector" => "$[::9007199254740992]",
      "tags" => ["boundary", "slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, overflowing to value" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, overflowing to value",
      "selector" =>
        "$[2:231584178474632390847141970017375815706539969331281128078915168015826259279872]",
      "tags" => ["boundary", "slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, underflowing from value" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, underflowing from value",
      "selector" =>
        "$[-231584178474632390847141970017375815706539969331281128078915168015826259279872:1]",
      "tags" => ["boundary", "slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, overflowing from value with negative step" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, overflowing from value with negative step",
      "selector" =>
        "$[231584178474632390847141970017375815706539969331281128078915168015826259279872:0:-1]",
      "tags" => ["boundary", "slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, underflowing to value with negative step" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, underflowing to value with negative step",
      "selector" =>
        "$[3:-231584178474632390847141970017375815706539969331281128078915168015826259279872:-1]",
      "tags" => ["boundary", "slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, overflowing step" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, overflowing step",
      "selector" =>
        "$[1:10:231584178474632390847141970017375815706539969331281128078915168015826259279872]",
      "tags" => ["boundary", "slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, underflowing step" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, underflowing step",
      "selector" =>
        "$[-1:-10:-231584178474632390847141970017375815706539969331281128078915168015826259279872]",
      "tags" => ["boundary", "slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, start, leading 0" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, start, leading 0",
      "selector" => "$[01::]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, start, decimal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, start, decimal",
      "selector" => "$[1.0::]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, start, plus" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, start, plus",
      "selector" => "$[+1::]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, start, minus space" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, start, minus space",
      "selector" => "$[- 1::]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, start, -0" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, start, -0",
      "selector" => "$[-0::]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, start, leading -0" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, start, leading -0",
      "selector" => "$[-01::]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, end, leading 0" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, end, leading 0",
      "selector" => "$[:01:]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, end, decimal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, end, decimal",
      "selector" => "$[:1.0:]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, end, plus" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, end, plus",
      "selector" => "$[:+1:]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, end, minus space" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, end, minus space",
      "selector" => "$[:- 1:]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, end, -0" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, end, -0",
      "selector" => "$[:-0:]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, end, leading -0" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, end, leading -0",
      "selector" => "$[:-01:]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, step, leading 0" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, step, leading 0",
      "selector" => "$[::01]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, step, decimal" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, step, decimal",
      "selector" => "$[::1.0]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, step, plus" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, step, plus",
      "selector" => "$[::+1]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, step, minus space" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, step, minus space",
      "selector" => "$[::- 1]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, step, -0" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, step, -0",
      "selector" => "$[::-0]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "slice selector, step, leading -0" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "slice selector, step, leading -0",
      "selector" => "$[::-01]",
      "tags" => ["slice"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "functions, count, count function" do
    testcase = %{
      "document" => [%{"a" => [1, 2, 3]}, %{"a" => [1], "d" => "f"}, %{"a" => 1, "d" => "f"}],
      "name" => "functions, count, count function",
      "result" => [%{"a" => [1, 2, 3]}, %{"a" => [1], "d" => "f"}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?count(@..*)>2]",
      "tags" => ["count", "function"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, count, single-node arg" do
    testcase = %{
      "document" => [%{"a" => [1, 2, 3]}, %{"a" => [1], "d" => "f"}, %{"a" => 1, "d" => "f"}],
      "name" => "functions, count, single-node arg",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[?count(@.a)>1]",
      "tags" => ["count", "function"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, count, multiple-selector arg" do
    testcase = %{
      "document" => [%{"a" => [1, 2, 3]}, %{"a" => [1], "d" => "f"}, %{"a" => 1, "d" => "f"}],
      "name" => "functions, count, multiple-selector arg",
      "result" => [%{"a" => [1], "d" => "f"}, %{"a" => 1, "d" => "f"}],
      "result_paths" => ["$[1]", "$[2]"],
      "selector" => "$[?count(@['a','d'])>1]",
      "tags" => ["count", "function"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, count, non-query arg, number" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "functions, count, non-query arg, number",
      "selector" => "$[?count(1)>2]",
      "tags" => ["count", "function"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "functions, count, non-query arg, string" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "functions, count, non-query arg, string",
      "selector" => "$[?count('string')>2]",
      "tags" => ["count", "function"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "functions, count, non-query arg, true" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "functions, count, non-query arg, true",
      "selector" => "$[?count(true)>2]",
      "tags" => ["count", "function"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "functions, count, non-query arg, false" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "functions, count, non-query arg, false",
      "selector" => "$[?count(false)>2]",
      "tags" => ["count", "function"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "functions, count, non-query arg, null" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "functions, count, non-query arg, null",
      "selector" => "$[?count(null)>2]",
      "tags" => ["count", "function"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "functions, count, result must be compared" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "functions, count, result must be compared",
      "selector" => "$[?count(@..*)]",
      "tags" => ["count", "function"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "functions, count, no params" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "functions, count, no params",
      "selector" => "$[?count()==1]",
      "tags" => ["count", "function"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "functions, count, too many params" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "functions, count, too many params",
      "selector" => "$[?count(@.a,@.b)==1]",
      "tags" => ["count", "function"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "functions, length, string data" do
    testcase = %{
      "document" => [%{"a" => "ab"}, %{"a" => "d"}],
      "name" => "functions, length, string data",
      "result" => [%{"a" => "ab"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?length(@.a)>=2]",
      "tags" => ["function", "length"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, length, string data, unicode" do
    testcase = %{
      "document" => ["☺", "☺☺", "☺☺☺", "ж", "жж", "жжж", "磨", "阿美", "形声字"],
      "name" => "functions, length, string data, unicode",
      "result" => ["☺☺", "жж", "阿美"],
      "result_paths" => ["$[1]", "$[4]", "$[7]"],
      "selector" => "$[?length(@)==2]",
      "tags" => ["function", "length"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, length, array data" do
    testcase = %{
      "document" => [%{"a" => [1, 2, 3]}, %{"a" => [1]}],
      "name" => "functions, length, array data",
      "result" => [%{"a" => [1, 2, 3]}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?length(@.a)>=2]",
      "tags" => ["function", "length"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, length, missing data" do
    testcase = %{
      "document" => [%{"d" => "f"}],
      "name" => "functions, length, missing data",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[?length(@.a)>=2]",
      "tags" => ["function", "length"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, length, number arg" do
    testcase = %{
      "document" => [%{"d" => "f"}],
      "name" => "functions, length, number arg",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[?length(1)>=2]",
      "tags" => ["function", "length"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, length, true arg" do
    testcase = %{
      "document" => [%{"d" => "f"}],
      "name" => "functions, length, true arg",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[?length(true)>=2]",
      "tags" => ["function", "length"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, length, false arg" do
    testcase = %{
      "document" => [%{"d" => "f"}],
      "name" => "functions, length, false arg",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[?length(false)>=2]",
      "tags" => ["function", "length"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, length, null arg" do
    testcase = %{
      "document" => [%{"d" => "f"}],
      "name" => "functions, length, null arg",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[?length(null)>=2]",
      "tags" => ["function", "length"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, length, result must be compared" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "functions, length, result must be compared",
      "selector" => "$[?length(@.a)]",
      "tags" => ["function", "length"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "functions, length, no params" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "functions, length, no params",
      "selector" => "$[?length()==1]",
      "tags" => ["function", "length"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "functions, length, too many params" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "functions, length, too many params",
      "selector" => "$[?length(@.a,@.b)==1]",
      "tags" => ["function", "length"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "functions, length, non-singular query arg" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "functions, length, non-singular query arg",
      "selector" => "$[?length(@.*)<3]",
      "tags" => ["function", "length"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "functions, length, arg is a function expression" do
    testcase = %{
      "document" => %{"c" => "cd", "values" => [%{"a" => "ab"}, %{"a" => "d"}]},
      "name" => "functions, length, arg is a function expression",
      "result" => [%{"a" => "ab"}],
      "result_paths" => ["$['values'][0]"],
      "selector" => "$.values[?length(@.a)==length(value($..c))]",
      "tags" => ["function", "length"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, length, arg is special nothing" do
    testcase = %{
      "document" => [%{"a" => "ab"}, %{"c" => "d"}, %{"a" => nil}],
      "name" => "functions, length, arg is special nothing",
      "result" => [%{"a" => "ab"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?length(value(@.a))>0]",
      "tags" => ["function", "length"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, length, non-singular query arg, multiple index selectors" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "functions, length, non-singular query arg, multiple index selectors",
      "selector" => "$[?length(@[1, 2])<3]",
      "tags" => ["function", "length"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "functions, length, non-singular query arg, multiple name selectors" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "functions, length, non-singular query arg, multiple name selectors",
      "selector" => "$[?length(@['a', 'b'])<3]",
      "tags" => ["function", "length"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "functions, match, found match" do
    testcase = %{
      "document" => [%{"a" => "ab"}],
      "name" => "functions, match, found match",
      "result" => [%{"a" => "ab"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?match(@.a, 'a.*')]",
      "tags" => ["function", "match"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, match, double quotes" do
    testcase = %{
      "document" => [%{"a" => "ab"}],
      "name" => "functions, match, double quotes",
      "result" => [%{"a" => "ab"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?match(@.a, \"a.*\")]",
      "tags" => ["function", "match"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, match, regex from the document" do
    testcase = %{
      "document" => %{
        "regex" => "b.?b",
        "values" => ["abc", "bcd", "bab", "bba", "bbab", "b", true, [], %{}]
      },
      "name" => "functions, match, regex from the document",
      "result" => ["bab"],
      "result_paths" => ["$['values'][2]"],
      "selector" => "$.values[?match(@, $.regex)]",
      "tags" => ["function", "match"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, match, don't select match" do
    testcase = %{
      "document" => [%{"a" => "ab"}],
      "name" => "functions, match, don't select match",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[?!match(@.a, 'a.*')]",
      "tags" => ["function", "match"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, match, not a match" do
    testcase = %{
      "document" => [%{"a" => "bc"}],
      "name" => "functions, match, not a match",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[?match(@.a, 'a.*')]",
      "tags" => ["function", "match"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, match, select non-match" do
    testcase = %{
      "document" => [%{"a" => "bc"}],
      "name" => "functions, match, select non-match",
      "result" => [%{"a" => "bc"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?!match(@.a, 'a.*')]",
      "tags" => ["function", "match"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, match, non-string first arg" do
    testcase = %{
      "document" => [%{"a" => "bc"}],
      "name" => "functions, match, non-string first arg",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[?match(1, 'a.*')]",
      "tags" => ["function", "match"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, match, non-string second arg" do
    testcase = %{
      "document" => [%{"a" => "bc"}],
      "name" => "functions, match, non-string second arg",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[?match(@.a, 1)]",
      "tags" => ["function", "match"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, match, filter, match function, unicode char class, uppercase" do
    testcase = %{
      "document" => ["ж", "Ж", "1", "жЖ", true, [], %{}],
      "name" => "functions, match, filter, match function, unicode char class, uppercase",
      "result" => ["Ж"],
      "result_paths" => ["$[1]"],
      "selector" => "$[?match(@, '\\\\p{Lu}')]",
      "tags" => ["function", "match"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, match, filter, match function, unicode char class negated, uppercase" do
    testcase = %{
      "document" => ["ж", "Ж", "1", true, [], %{}],
      "name" => "functions, match, filter, match function, unicode char class negated, uppercase",
      "result" => ["ж", "1"],
      "result_paths" => ["$[0]", "$[2]"],
      "selector" => "$[?match(@, '\\\\P{Lu}')]",
      "tags" => ["function", "match"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, match, filter, match function, unicode, surrogate pair" do
    testcase = %{
      "document" => ["a𐄁b", "ab", "1", true, [], %{}],
      "name" => "functions, match, filter, match function, unicode, surrogate pair",
      "result" => ["a𐄁b"],
      "result_paths" => ["$[0]"],
      "selector" => "$[?match(@, 'a.b')]",
      "tags" => ["function", "match"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  @tag :skip

  test "functions, match, dot matcher on \u2028" do
    testcase = %{
      "document" => ["", "\r", "\n", true, [], %{}],
      "name" => "functions, match, dot matcher on \\u2028",
      "result" => [""],
      "result_paths" => ["$[0]"],
      "selector" => "$[?match(@, '.')]",
      "skip" => true,
      "skip_reason" => "Codepoint is lost in document",
      "tags" => ["function", "match"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  @tag :skip

  test "functions, match, dot matcher on \u2029" do
    testcase = %{
      "document" => ["", "\r", "\n", true, [], %{}],
      "name" => "functions, match, dot matcher on \\u2029",
      "result" => [""],
      "result_paths" => ["$[0]"],
      "selector" => "$[?match(@, '.')]",
      "skip" => true,
      "skip_reason" => "Codepoint is lost in document",
      "tags" => ["function", "match"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, match, result cannot be compared" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "functions, match, result cannot be compared",
      "selector" => "$[?match(@.a, 'a.*')==true]",
      "tags" => ["function", "match"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "functions, match, too few params" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "functions, match, too few params",
      "selector" => "$[?match(@.a)==1]",
      "tags" => ["function", "match"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "functions, match, too many params" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "functions, match, too many params",
      "selector" => "$[?match(@.a,@.b,@.c)==1]",
      "tags" => ["function", "match"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "functions, match, arg is a function expression" do
    testcase = %{
      "document" => %{"regex" => "a.*", "values" => [%{"a" => "ab"}, %{"a" => "ba"}]},
      "name" => "functions, match, arg is a function expression",
      "result" => [%{"a" => "ab"}],
      "result_paths" => ["$['values'][0]"],
      "selector" => "$.values[?match(@.a, value($..['regex']))]",
      "tags" => ["function", "match"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, match, dot in character class" do
    testcase = %{
      "document" => ["abc", "a.c", "axc"],
      "name" => "functions, match, dot in character class",
      "result" => ["abc", "a.c"],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?match(@, 'a[.b]c')]",
      "tags" => ["function", "match"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, match, escaped dot" do
    testcase = %{
      "document" => ["abc", "a.c", "axc"],
      "name" => "functions, match, escaped dot",
      "result" => ["a.c"],
      "result_paths" => ["$[1]"],
      "selector" => "$[?match(@, 'a\\\\.c')]",
      "tags" => ["function", "match"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  @tag :skip

  test "functions, match, escaped backslash before dot" do
    testcase = %{
      "document" => ["abc", "a.c", "axc", "a\\c"],
      "name" => "functions, match, escaped backslash before dot",
      "result" => ["a\\c"],
      "result_paths" => ["$[3]"],
      "selector" => "$[?match(@, 'a\\\\\\\\.c')]",
      "skip" => true,
      "skip_reason" => "Additional '.'",
      "tags" => ["function", "match"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  @tag :skip

  test "functions, match, escaped left square bracket" do
    testcase = %{
      "document" => ["abc", "a.c", "a[c"],
      "name" => "functions, match, escaped left square bracket",
      "result" => ["a[c"],
      "result_paths" => ["$[2]"],
      "selector" => "$[?match(@, 'a\\\\[.c')]",
      "skip" => true,
      "skip_reason" => "Additional '.'",
      "tags" => ["function", "match"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, match, escaped right square bracket" do
    testcase = %{
      "document" => ["abc", "a.c", "ac", "a]c"],
      "name" => "functions, match, escaped right square bracket",
      "result" => ["a.c", "a]c"],
      "result_paths" => ["$[1]", "$[3]"],
      "selector" => "$[?match(@, 'a[\\\\].]c')]",
      "tags" => ["function", "match"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, match, explicit caret" do
    testcase = %{
      "document" => ["abc", "axc", "ab", "xab"],
      "name" => "functions, match, explicit caret",
      "result" => ["abc", "ab"],
      "result_paths" => ["$[0]", "$[2]"],
      "selector" => "$[?match(@, '^ab.*')]",
      "tags" => ["function", "match"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, match, explicit dollar" do
    testcase = %{
      "document" => ["abc", "axc", "ab", "abcx"],
      "name" => "functions, match, explicit dollar",
      "result" => ["abc"],
      "result_paths" => ["$[0]"],
      "selector" => "$[?match(@, '.*bc$')]",
      "tags" => ["function", "match"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, search, at the end" do
    testcase = %{
      "document" => [%{"a" => "the end is ab"}],
      "name" => "functions, search, at the end",
      "result" => [%{"a" => "the end is ab"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?search(@.a, 'a.*')]",
      "tags" => ["function", "search"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, search, double quotes" do
    testcase = %{
      "document" => [%{"a" => "the end is ab"}],
      "name" => "functions, search, double quotes",
      "result" => [%{"a" => "the end is ab"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?search(@.a, \"a.*\")]",
      "tags" => ["function", "search"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, search, at the start" do
    testcase = %{
      "document" => [%{"a" => "ab is at the start"}],
      "name" => "functions, search, at the start",
      "result" => [%{"a" => "ab is at the start"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?search(@.a, 'a.*')]",
      "tags" => ["function", "search"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, search, in the middle" do
    testcase = %{
      "document" => [%{"a" => "contains two matches"}],
      "name" => "functions, search, in the middle",
      "result" => [%{"a" => "contains two matches"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?search(@.a, 'a.*')]",
      "tags" => ["function", "search"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, search, regex from the document" do
    testcase = %{
      "document" => %{
        "regex" => "b.?b",
        "values" => ["abc", "bcd", "bab", "bba", "bbab", "b", true, [], %{}]
      },
      "name" => "functions, search, regex from the document",
      "result" => ["bab", "bba", "bbab"],
      "result_paths" => ["$['values'][2]", "$['values'][3]", "$['values'][4]"],
      "selector" => "$.values[?search(@, $.regex)]",
      "tags" => ["function", "search"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, search, don't select match" do
    testcase = %{
      "document" => [%{"a" => "contains two matches"}],
      "name" => "functions, search, don't select match",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[?!search(@.a, 'a.*')]",
      "tags" => ["function", "search"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, search, not a match" do
    testcase = %{
      "document" => [%{"a" => "bc"}],
      "name" => "functions, search, not a match",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[?search(@.a, 'a.*')]",
      "tags" => ["function", "search"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, search, select non-match" do
    testcase = %{
      "document" => [%{"a" => "bc"}],
      "name" => "functions, search, select non-match",
      "result" => [%{"a" => "bc"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?!search(@.a, 'a.*')]",
      "tags" => ["function", "search"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, search, non-string first arg" do
    testcase = %{
      "document" => [%{"a" => "bc"}],
      "name" => "functions, search, non-string first arg",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[?search(1, 'a.*')]",
      "tags" => ["function", "search"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, search, non-string second arg" do
    testcase = %{
      "document" => [%{"a" => "bc"}],
      "name" => "functions, search, non-string second arg",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[?search(@.a, 1)]",
      "tags" => ["function", "search"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, search, filter, search function, unicode char class, uppercase" do
    testcase = %{
      "document" => ["ж", "Ж", "1", "жЖ", true, [], %{}],
      "name" => "functions, search, filter, search function, unicode char class, uppercase",
      "result" => ["Ж", "жЖ"],
      "result_paths" => ["$[1]", "$[3]"],
      "selector" => "$[?search(@, '\\\\p{Lu}')]",
      "tags" => ["function", "search"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, search, filter, search function, unicode char class negated, uppercase" do
    testcase = %{
      "document" => ["ж", "Ж", "1", true, [], %{}],
      "name" =>
        "functions, search, filter, search function, unicode char class negated, uppercase",
      "result" => ["ж", "1"],
      "result_paths" => ["$[0]", "$[2]"],
      "selector" => "$[?search(@, '\\\\P{Lu}')]",
      "tags" => ["function", "search"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, search, filter, search function, unicode, surrogate pair" do
    testcase = %{
      "document" => ["a𐄁bc", "abc", "1", true, [], %{}],
      "name" => "functions, search, filter, search function, unicode, surrogate pair",
      "result" => ["a𐄁bc"],
      "result_paths" => ["$[0]"],
      "selector" => "$[?search(@, 'a.b')]",
      "tags" => ["function", "search"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  @tag :skip

  test "functions, search, dot matcher on \u2028" do
    testcase = %{
      "document" => ["", "\r\n", "\r", "\n", true, [], %{}],
      "name" => "functions, search, dot matcher on \\u2028",
      "result" => ["", "\r\n"],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?search(@, '.')]",
      "skip" => true,
      "skip_reason" => "Codepoint is lost in document",
      "tags" => ["function", "search"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  @tag :skip

  test "functions, search, dot matcher on \u2029" do
    testcase = %{
      "document" => ["", "\r\n", "\r", "\n", true, [], %{}],
      "name" => "functions, search, dot matcher on \\u2029",
      "result" => ["", "\r\n"],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?search(@, '.')]",
      "skip" => true,
      "skip_reason" => "Codepoint is lost in document",
      "tags" => ["function", "search"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, search, result cannot be compared" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "functions, search, result cannot be compared",
      "selector" => "$[?search(@.a, 'a.*')==true]",
      "tags" => ["function", "search"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "functions, search, too few params" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "functions, search, too few params",
      "selector" => "$[?search(@.a)]",
      "tags" => ["function", "search"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "functions, search, too many params" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "functions, search, too many params",
      "selector" => "$[?search(@.a,@.b,@.c)]",
      "tags" => ["function", "search"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "functions, search, arg is a function expression" do
    testcase = %{
      "document" => %{
        "regex" => "b.?b",
        "values" => ["abc", "bcd", "bab", "bba", "bbab", "b", true, [], %{}]
      },
      "name" => "functions, search, arg is a function expression",
      "result" => ["bab", "bba", "bbab"],
      "result_paths" => ["$['values'][2]", "$['values'][3]", "$['values'][4]"],
      "selector" => "$.values[?search(@, value($..['regex']))]",
      "tags" => ["function", "search"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, search, dot in character class" do
    testcase = %{
      "document" => ["x abc y", "x a.c y", "x axc y"],
      "name" => "functions, search, dot in character class",
      "result" => ["x abc y", "x a.c y"],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?search(@, 'a[.b]c')]",
      "tags" => ["function", "search"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, search, escaped dot" do
    testcase = %{
      "document" => ["x abc y", "x a.c y", "x axc y"],
      "name" => "functions, search, escaped dot",
      "result" => ["x a.c y"],
      "result_paths" => ["$[1]"],
      "selector" => "$[?search(@, 'a\\\\.c')]",
      "tags" => ["function", "search"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  @tag :skip

  test "functions, search, escaped backslash before dot" do
    testcase = %{
      "document" => ["x abc y", "x a.c y", "x axc y", "x a\\c y"],
      "name" => "functions, search, escaped backslash before dot",
      "result" => ["x a\\c y"],
      "result_paths" => ["$[3]"],
      "selector" => "$[?search(@, 'a\\\\\\\\.c')]",
      "skip" => true,
      "skip_reason" => "Additional '.'",
      "tags" => ["function", "search"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  @tag :skip

  test "functions, search, escaped left square bracket" do
    testcase = %{
      "document" => ["x abc y", "x a.c y", "x a[c y"],
      "name" => "functions, search, escaped left square bracket",
      "result" => ["x a[c y"],
      "result_paths" => ["$[2]"],
      "selector" => "$[?search(@, 'a\\\\[.c')]",
      "skip" => true,
      "skip_reason" => "Additional '.'",
      "tags" => ["function", "search"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, search, escaped right square bracket" do
    testcase = %{
      "document" => ["x abc y", "x a.c y", "x ac y", "x a]c y"],
      "name" => "functions, search, escaped right square bracket",
      "result" => ["x a.c y", "x a]c y"],
      "result_paths" => ["$[1]", "$[3]"],
      "selector" => "$[?search(@, 'a[\\\\].]c')]",
      "tags" => ["function", "search"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, value, single-value nodelist" do
    testcase = %{
      "document" => [[4], %{"foo" => 4}, [5], %{"foo" => 5}, 4],
      "name" => "functions, value, single-value nodelist",
      "result" => [[4], %{"foo" => 4}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?value(@.*)==4]",
      "tags" => ["function", "value"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, value, multi-value nodelist" do
    testcase = %{
      "document" => [[4, 4], %{"bar" => 4, "foo" => 4}],
      "name" => "functions, value, multi-value nodelist",
      "result" => [],
      "result_paths" => [],
      "selector" => "$[?value(@.*)==4]",
      "tags" => ["function", "value"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "functions, value, too few params" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "functions, value, too few params",
      "selector" => "$[?value()==4]",
      "tags" => ["function", "value"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "functions, value, too many params" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "functions, value, too many params",
      "selector" => "$[?value(@.a,@.b)==4]",
      "tags" => ["function", "value"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "functions, value, result must be compared" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "functions, value, result must be compared",
      "selector" => "$[?value(@.a)]",
      "tags" => ["function", "value"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "whitespace, filter, space between question mark and expression" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "name" => "whitespace, filter, space between question mark and expression",
      "result" => [%{"a" => "b", "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[? @.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, filter, newline between question mark and expression" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "name" => "whitespace, filter, newline between question mark and expression",
      "result" => [%{"a" => "b", "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?\n@.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, filter, tab between question mark and expression" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "name" => "whitespace, filter, tab between question mark and expression",
      "result" => [%{"a" => "b", "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?\t@.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, filter, return between question mark and expression" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "name" => "whitespace, filter, return between question mark and expression",
      "result" => [%{"a" => "b", "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?\r@.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, filter, space between question mark and parenthesized expression" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "name" => "whitespace, filter, space between question mark and parenthesized expression",
      "result" => [%{"a" => "b", "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[? (@.a)]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, filter, newline between question mark and parenthesized expression" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "name" => "whitespace, filter, newline between question mark and parenthesized expression",
      "result" => [%{"a" => "b", "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?\n(@.a)]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, filter, tab between question mark and parenthesized expression" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "name" => "whitespace, filter, tab between question mark and parenthesized expression",
      "result" => [%{"a" => "b", "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?\t(@.a)]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, filter, return between question mark and parenthesized expression" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "name" => "whitespace, filter, return between question mark and parenthesized expression",
      "result" => [%{"a" => "b", "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?\r(@.a)]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, filter, space between parenthesized expression and bracket" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "name" => "whitespace, filter, space between parenthesized expression and bracket",
      "result" => [%{"a" => "b", "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?(@.a) ]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, filter, newline between parenthesized expression and bracket" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "name" => "whitespace, filter, newline between parenthesized expression and bracket",
      "result" => [%{"a" => "b", "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?(@.a)\n]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, filter, tab between parenthesized expression and bracket" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "name" => "whitespace, filter, tab between parenthesized expression and bracket",
      "result" => [%{"a" => "b", "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?(@.a)\t]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, filter, return between parenthesized expression and bracket" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "name" => "whitespace, filter, return between parenthesized expression and bracket",
      "result" => [%{"a" => "b", "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?(@.a)\r]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, filter, space between bracket and question mark" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "name" => "whitespace, filter, space between bracket and question mark",
      "result" => [%{"a" => "b", "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[ ?@.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, filter, newline between bracket and question mark" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "name" => "whitespace, filter, newline between bracket and question mark",
      "result" => [%{"a" => "b", "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[\n?@.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, filter, tab between bracket and question mark" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "name" => "whitespace, filter, tab between bracket and question mark",
      "result" => [%{"a" => "b", "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[\t?@.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, filter, return between bracket and question mark" do
    testcase = %{
      "document" => [%{"a" => "b", "d" => "e"}, %{"b" => "c", "d" => "f"}],
      "name" => "whitespace, filter, return between bracket and question mark",
      "result" => [%{"a" => "b", "d" => "e"}],
      "result_paths" => ["$[0]"],
      "selector" => "$[\r?@.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, functions, space between function name and parenthesis" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "whitespace, functions, space between function name and parenthesis",
      "selector" => "$[?count (@.*)==1]",
      "tags" => ["count", "function", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "whitespace, functions, newline between function name and parenthesis" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "whitespace, functions, newline between function name and parenthesis",
      "selector" => "$[?count\n(@.*)==1]",
      "tags" => ["count", "function", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "whitespace, functions, tab between function name and parenthesis" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "whitespace, functions, tab between function name and parenthesis",
      "selector" => "$[?count\t(@.*)==1]",
      "tags" => ["count", "function", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "whitespace, functions, return between function name and parenthesis" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "whitespace, functions, return between function name and parenthesis",
      "selector" => "$[?count\r(@.*)==1]",
      "tags" => ["count", "function", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "whitespace, functions, space between parenthesis and arg" do
    testcase = %{
      "document" => [%{"a" => 1}, %{"b" => 2}, %{"a" => 2, "b" => 1}],
      "name" => "whitespace, functions, space between parenthesis and arg",
      "result" => [%{"a" => 1}, %{"b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?count( @.*)==1]",
      "tags" => ["count", "function", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, functions, newline between parenthesis and arg" do
    testcase = %{
      "document" => [%{"a" => 1}, %{"b" => 2}, %{"a" => 2, "b" => 1}],
      "name" => "whitespace, functions, newline between parenthesis and arg",
      "result" => [%{"a" => 1}, %{"b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?count(\n@.*)==1]",
      "tags" => ["count", "function", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, functions, tab between parenthesis and arg" do
    testcase = %{
      "document" => [%{"a" => 1}, %{"b" => 2}, %{"a" => 2, "b" => 1}],
      "name" => "whitespace, functions, tab between parenthesis and arg",
      "result" => [%{"a" => 1}, %{"b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?count(\t@.*)==1]",
      "tags" => ["count", "function", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, functions, return between parenthesis and arg" do
    testcase = %{
      "document" => [%{"a" => 1}, %{"b" => 2}, %{"a" => 2, "b" => 1}],
      "name" => "whitespace, functions, return between parenthesis and arg",
      "result" => [%{"a" => 1}, %{"b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?count(\r@.*)==1]",
      "tags" => ["count", "function", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, functions, space between arg and comma" do
    testcase = %{
      "document" => ["foo", "123"],
      "name" => "whitespace, functions, space between arg and comma",
      "result" => ["foo"],
      "result_paths" => ["$[0]"],
      "selector" => "$[?search(@ ,'[a-z]+')]",
      "tags" => ["function", "search", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, functions, newline between arg and comma" do
    testcase = %{
      "document" => ["foo", "123"],
      "name" => "whitespace, functions, newline between arg and comma",
      "result" => ["foo"],
      "result_paths" => ["$[0]"],
      "selector" => "$[?search(@\n,'[a-z]+')]",
      "tags" => ["function", "search", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, functions, tab between arg and comma" do
    testcase = %{
      "document" => ["foo", "123"],
      "name" => "whitespace, functions, tab between arg and comma",
      "result" => ["foo"],
      "result_paths" => ["$[0]"],
      "selector" => "$[?search(@\t,'[a-z]+')]",
      "tags" => ["function", "search", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, functions, return between arg and comma" do
    testcase = %{
      "document" => ["foo", "123"],
      "name" => "whitespace, functions, return between arg and comma",
      "result" => ["foo"],
      "result_paths" => ["$[0]"],
      "selector" => "$[?search(@\r,'[a-z]+')]",
      "tags" => ["function", "search", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, functions, space between comma and arg" do
    testcase = %{
      "document" => ["foo", "123"],
      "name" => "whitespace, functions, space between comma and arg",
      "result" => ["foo"],
      "result_paths" => ["$[0]"],
      "selector" => "$[?search(@, '[a-z]+')]",
      "tags" => ["function", "search", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, functions, newline between comma and arg" do
    testcase = %{
      "document" => ["foo", "123"],
      "name" => "whitespace, functions, newline between comma and arg",
      "result" => ["foo"],
      "result_paths" => ["$[0]"],
      "selector" => "$[?search(@,\n'[a-z]+')]",
      "tags" => ["function", "search", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, functions, tab between comma and arg" do
    testcase = %{
      "document" => ["foo", "123"],
      "name" => "whitespace, functions, tab between comma and arg",
      "result" => ["foo"],
      "result_paths" => ["$[0]"],
      "selector" => "$[?search(@,\t'[a-z]+')]",
      "tags" => ["function", "search", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, functions, return between comma and arg" do
    testcase = %{
      "document" => ["foo", "123"],
      "name" => "whitespace, functions, return between comma and arg",
      "result" => ["foo"],
      "result_paths" => ["$[0]"],
      "selector" => "$[?search(@,\r'[a-z]+')]",
      "tags" => ["function", "search", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, functions, space between arg and parenthesis" do
    testcase = %{
      "document" => [%{"a" => 1}, %{"b" => 2}, %{"a" => 2, "b" => 1}],
      "name" => "whitespace, functions, space between arg and parenthesis",
      "result" => [%{"a" => 1}, %{"b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?count(@.* )==1]",
      "tags" => ["function", "search", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, functions, newline between arg and parenthesis" do
    testcase = %{
      "document" => [%{"a" => 1}, %{"b" => 2}, %{"a" => 2, "b" => 1}],
      "name" => "whitespace, functions, newline between arg and parenthesis",
      "result" => [%{"a" => 1}, %{"b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?count(@.*\n)==1]",
      "tags" => ["count", "function", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, functions, tab between arg and parenthesis" do
    testcase = %{
      "document" => [%{"a" => 1}, %{"b" => 2}, %{"a" => 2, "b" => 1}],
      "name" => "whitespace, functions, tab between arg and parenthesis",
      "result" => [%{"a" => 1}, %{"b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?count(@.*\t)==1]",
      "tags" => ["count", "function", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, functions, return between arg and parenthesis" do
    testcase = %{
      "document" => [%{"a" => 1}, %{"b" => 2}, %{"a" => 2, "b" => 1}],
      "name" => "whitespace, functions, return between arg and parenthesis",
      "result" => [%{"a" => 1}, %{"b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?count(@.*\r)==1]",
      "tags" => ["count", "function", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, functions, spaces in a relative singular selector" do
    testcase = %{
      "document" => [%{"a" => %{"b" => "foo"}}, %{}],
      "name" => "whitespace, functions, spaces in a relative singular selector",
      "result" => [%{"a" => %{"b" => "foo"}}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?length(@ .a .b) == 3]",
      "tags" => ["function", "length", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, functions, newlines in a relative singular selector" do
    testcase = %{
      "document" => [%{"a" => %{"b" => "foo"}}, %{}],
      "name" => "whitespace, functions, newlines in a relative singular selector",
      "result" => [%{"a" => %{"b" => "foo"}}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?length(@\n.a\n.b) == 3]",
      "tags" => ["function", "length", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, functions, tabs in a relative singular selector" do
    testcase = %{
      "document" => [%{"a" => %{"b" => "foo"}}, %{}],
      "name" => "whitespace, functions, tabs in a relative singular selector",
      "result" => [%{"a" => %{"b" => "foo"}}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?length(@\t.a\t.b) == 3]",
      "tags" => ["function", "length", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, functions, returns in a relative singular selector" do
    testcase = %{
      "document" => [%{"a" => %{"b" => "foo"}}, %{}],
      "name" => "whitespace, functions, returns in a relative singular selector",
      "result" => [%{"a" => %{"b" => "foo"}}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?length(@\r.a\r.b) == 3]",
      "tags" => ["function", "length", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, functions, spaces in an absolute singular selector" do
    testcase = %{
      "document" => [%{"a" => "foo"}, %{}],
      "name" => "whitespace, functions, spaces in an absolute singular selector",
      "result" => ["foo"],
      "result_paths" => ["$[0]['a']"],
      "selector" => "$..[?length(@)==length($ [0] .a)]",
      "tags" => ["function", "length", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, functions, newlines in an absolute singular selector" do
    testcase = %{
      "document" => [%{"a" => "foo"}, %{}],
      "name" => "whitespace, functions, newlines in an absolute singular selector",
      "result" => ["foo"],
      "result_paths" => ["$[0]['a']"],
      "selector" => "$..[?length(@)==length($\n[0]\n.a)]",
      "tags" => ["function", "length", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, functions, tabs in an absolute singular selector" do
    testcase = %{
      "document" => [%{"a" => "foo"}, %{}],
      "name" => "whitespace, functions, tabs in an absolute singular selector",
      "result" => ["foo"],
      "result_paths" => ["$[0]['a']"],
      "selector" => "$..[?length(@)==length($\t[0]\t.a)]",
      "tags" => ["function", "length", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, functions, returns in an absolute singular selector" do
    testcase = %{
      "document" => [%{"a" => "foo"}, %{}],
      "name" => "whitespace, functions, returns in an absolute singular selector",
      "result" => ["foo"],
      "result_paths" => ["$[0]['a']"],
      "selector" => "$..[?length(@)==length($\r[0]\r.a)]",
      "tags" => ["function", "length", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, space before ||" do
    testcase = %{
      "document" => [%{"a" => 1}, %{"b" => 2}, %{"c" => 3}],
      "name" => "whitespace, operators, space before ||",
      "result" => [%{"a" => 1}, %{"b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.a ||@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, newline before ||" do
    testcase = %{
      "document" => [%{"a" => 1}, %{"b" => 2}, %{"c" => 3}],
      "name" => "whitespace, operators, newline before ||",
      "result" => [%{"a" => 1}, %{"b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.a\n||@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, tab before ||" do
    testcase = %{
      "document" => [%{"a" => 1}, %{"b" => 2}, %{"c" => 3}],
      "name" => "whitespace, operators, tab before ||",
      "result" => [%{"a" => 1}, %{"b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.a\t||@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, return before ||" do
    testcase = %{
      "document" => [%{"a" => 1}, %{"b" => 2}, %{"c" => 3}],
      "name" => "whitespace, operators, return before ||",
      "result" => [%{"a" => 1}, %{"b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.a\r||@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, space after ||" do
    testcase = %{
      "document" => [%{"a" => 1}, %{"b" => 2}, %{"c" => 3}],
      "name" => "whitespace, operators, space after ||",
      "result" => [%{"a" => 1}, %{"b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.a|| @.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, newline after ||" do
    testcase = %{
      "document" => [%{"a" => 1}, %{"b" => 2}, %{"c" => 3}],
      "name" => "whitespace, operators, newline after ||",
      "result" => [%{"a" => 1}, %{"b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.a||\n@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, tab after ||" do
    testcase = %{
      "document" => [%{"a" => 1}, %{"b" => 2}, %{"c" => 3}],
      "name" => "whitespace, operators, tab after ||",
      "result" => [%{"a" => 1}, %{"b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.a||\t@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, return after ||" do
    testcase = %{
      "document" => [%{"a" => 1}, %{"b" => 2}, %{"c" => 3}],
      "name" => "whitespace, operators, return after ||",
      "result" => [%{"a" => 1}, %{"b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.a||\r@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, space before &&" do
    testcase = %{
      "document" => [%{"a" => 1}, %{"b" => 2}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, space before &&",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[2]"],
      "selector" => "$[?@.a &&@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, newline before &&" do
    testcase = %{
      "document" => [%{"a" => 1}, %{"b" => 2}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, newline before &&",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[2]"],
      "selector" => "$[?@.a\n&&@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, tab before &&" do
    testcase = %{
      "document" => [%{"a" => 1}, %{"b" => 2}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, tab before &&",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[2]"],
      "selector" => "$[?@.a\t&&@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, return before &&" do
    testcase = %{
      "document" => [%{"a" => 1}, %{"b" => 2}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, return before &&",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[2]"],
      "selector" => "$[?@.a\r&&@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, space after &&" do
    testcase = %{
      "document" => [%{"a" => 1}, %{"b" => 2}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, space after &&",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[2]"],
      "selector" => "$[?@.a&& @.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, newline after &&" do
    testcase = %{
      "document" => [%{"a" => 1}, %{"b" => 2}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, newline after &&",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[2]"],
      "selector" => "$[?@.a&& @.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, tab after &&" do
    testcase = %{
      "document" => [%{"a" => 1}, %{"b" => 2}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, tab after &&",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[2]"],
      "selector" => "$[?@.a&& @.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, return after &&" do
    testcase = %{
      "document" => [%{"a" => 1}, %{"b" => 2}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, return after &&",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[2]"],
      "selector" => "$[?@.a&& @.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, space before ==" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, space before ==",
      "result" => [%{"a" => 1, "b" => 1}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a ==@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, newline before ==" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, newline before ==",
      "result" => [%{"a" => 1, "b" => 1}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a\n==@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, tab before ==" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, tab before ==",
      "result" => [%{"a" => 1, "b" => 1}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a\t==@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, return before ==" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, return before ==",
      "result" => [%{"a" => 1, "b" => 1}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a\r==@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, space after ==" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, space after ==",
      "result" => [%{"a" => 1, "b" => 1}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a== @.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, newline after ==" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, newline after ==",
      "result" => [%{"a" => 1, "b" => 1}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==\n@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, tab after ==" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, tab after ==",
      "result" => [%{"a" => 1, "b" => 1}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==\t@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, return after ==" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, return after ==",
      "result" => [%{"a" => 1, "b" => 1}],
      "result_paths" => ["$[0]"],
      "selector" => "$[?@.a==\r@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, space before !=" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, space before !=",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a !=@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, newline before !=" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, newline before !=",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a\n!=@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, tab before !=" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, tab before !=",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a\t!=@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, return before !=" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, return before !=",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a\r!=@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, space after !=" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, space after !=",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a!= @.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, newline after !=" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, newline after !=",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a!=\n@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, tab after !=" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, tab after !=",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a!=\t@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, return after !=" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, return after !=",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a!=\r@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, space before <" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, space before <",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a <@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, newline before <" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, newline before <",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a\n<@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, tab before <" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, tab before <",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a\t<@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, return before <" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, return before <",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a\r<@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, space after <" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, space after <",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a< @.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, newline after <" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, newline after <",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a<\n@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, tab after <" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, tab after <",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a<\t@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, return after <" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, return after <",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.a<\r@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, space before >" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, space before >",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.b >@.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, newline before >" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, newline before >",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.b\n>@.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, tab before >" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, tab before >",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.b\t>@.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, return before >" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, return before >",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.b\r>@.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, space after >" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, space after >",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.b> @.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, newline after >" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, newline after >",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.b>\n@.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, tab after >" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, tab after >",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.b>\t@.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, return after >" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "name" => "whitespace, operators, return after >",
      "result" => [%{"a" => 1, "b" => 2}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?@.b>\r@.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, space before <=" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}, %{"a" => 2, "b" => 1}],
      "name" => "whitespace, operators, space before <=",
      "result" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.a <=@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, newline before <=" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}, %{"a" => 2, "b" => 1}],
      "name" => "whitespace, operators, newline before <=",
      "result" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.a\n<=@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, tab before <=" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}, %{"a" => 2, "b" => 1}],
      "name" => "whitespace, operators, tab before <=",
      "result" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.a\t<=@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, return before <=" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}, %{"a" => 2, "b" => 1}],
      "name" => "whitespace, operators, return before <=",
      "result" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.a\r<=@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, space after <=" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}, %{"a" => 2, "b" => 1}],
      "name" => "whitespace, operators, space after <=",
      "result" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.a<= @.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, newline after <=" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}, %{"a" => 2, "b" => 1}],
      "name" => "whitespace, operators, newline after <=",
      "result" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.a<=\n@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, tab after <=" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}, %{"a" => 2, "b" => 1}],
      "name" => "whitespace, operators, tab after <=",
      "result" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.a<=\t@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, return after <=" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}, %{"a" => 2, "b" => 1}],
      "name" => "whitespace, operators, return after <=",
      "result" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.a<=\r@.b]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, space before >=" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}, %{"a" => 2, "b" => 1}],
      "name" => "whitespace, operators, space before >=",
      "result" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.b >=@.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, newline before >=" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}, %{"a" => 2, "b" => 1}],
      "name" => "whitespace, operators, newline before >=",
      "result" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.b\n>=@.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, tab before >=" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}, %{"a" => 2, "b" => 1}],
      "name" => "whitespace, operators, tab before >=",
      "result" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.b\t>=@.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, return before >=" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}, %{"a" => 2, "b" => 1}],
      "name" => "whitespace, operators, return before >=",
      "result" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.b\r>=@.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, space after >=" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}, %{"a" => 2, "b" => 1}],
      "name" => "whitespace, operators, space after >=",
      "result" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.b>= @.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, newline after >=" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}, %{"a" => 2, "b" => 1}],
      "name" => "whitespace, operators, newline after >=",
      "result" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.b>=\n@.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, tab after >=" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}, %{"a" => 2, "b" => 1}],
      "name" => "whitespace, operators, tab after >=",
      "result" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.b>=\t@.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, return after >=" do
    testcase = %{
      "document" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}, %{"a" => 2, "b" => 1}],
      "name" => "whitespace, operators, return after >=",
      "result" => [%{"a" => 1, "b" => 1}, %{"a" => 1, "b" => 2}],
      "result_paths" => ["$[0]", "$[1]"],
      "selector" => "$[?@.b>=\r@.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, space between logical not and test expression" do
    testcase = %{
      "document" => [%{"a" => "a", "d" => "e"}, %{"d" => "f"}, %{"a" => "d", "d" => "f"}],
      "name" => "whitespace, operators, space between logical not and test expression",
      "result" => [%{"d" => "f"}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?! @.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, newline between logical not and test expression" do
    testcase = %{
      "document" => [%{"a" => "a", "d" => "e"}, %{"d" => "f"}, %{"a" => "d", "d" => "f"}],
      "name" => "whitespace, operators, newline between logical not and test expression",
      "result" => [%{"d" => "f"}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?!\n@.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, tab between logical not and test expression" do
    testcase = %{
      "document" => [%{"a" => "a", "d" => "e"}, %{"d" => "f"}, %{"a" => "d", "d" => "f"}],
      "name" => "whitespace, operators, tab between logical not and test expression",
      "result" => [%{"d" => "f"}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?!\t@.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, return between logical not and test expression" do
    testcase = %{
      "document" => [%{"a" => "a", "d" => "e"}, %{"d" => "f"}, %{"a" => "d", "d" => "f"}],
      "name" => "whitespace, operators, return between logical not and test expression",
      "result" => [%{"d" => "f"}],
      "result_paths" => ["$[1]"],
      "selector" => "$[?!\r@.a]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, space between logical not and parenthesized expression" do
    testcase = %{
      "document" => [
        %{"a" => "a", "d" => "e"},
        %{"a" => "b", "d" => "f"},
        %{"a" => "d", "d" => "f"}
      ],
      "name" => "whitespace, operators, space between logical not and parenthesized expression",
      "result" => [%{"a" => "a", "d" => "e"}, %{"a" => "d", "d" => "f"}],
      "result_paths" => ["$[0]", "$[2]"],
      "selector" => "$[?! (@.a=='b')]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, newline between logical not and parenthesized expression" do
    testcase = %{
      "document" => [
        %{"a" => "a", "d" => "e"},
        %{"a" => "b", "d" => "f"},
        %{"a" => "d", "d" => "f"}
      ],
      "name" => "whitespace, operators, newline between logical not and parenthesized expression",
      "result" => [%{"a" => "a", "d" => "e"}, %{"a" => "d", "d" => "f"}],
      "result_paths" => ["$[0]", "$[2]"],
      "selector" => "$[?!\n(@.a=='b')]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, tab between logical not and parenthesized expression" do
    testcase = %{
      "document" => [
        %{"a" => "a", "d" => "e"},
        %{"a" => "b", "d" => "f"},
        %{"a" => "d", "d" => "f"}
      ],
      "name" => "whitespace, operators, tab between logical not and parenthesized expression",
      "result" => [%{"a" => "a", "d" => "e"}, %{"a" => "d", "d" => "f"}],
      "result_paths" => ["$[0]", "$[2]"],
      "selector" => "$[?!\t(@.a=='b')]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, operators, return between logical not and parenthesized expression" do
    testcase = %{
      "document" => [
        %{"a" => "a", "d" => "e"},
        %{"a" => "b", "d" => "f"},
        %{"a" => "d", "d" => "f"}
      ],
      "name" => "whitespace, operators, return between logical not and parenthesized expression",
      "result" => [%{"a" => "a", "d" => "e"}, %{"a" => "d", "d" => "f"}],
      "result_paths" => ["$[0]", "$[2]"],
      "selector" => "$[?!\r(@.a=='b')]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, space between root and bracket" do
    testcase = %{
      "document" => %{"a" => "ab"},
      "name" => "whitespace, selectors, space between root and bracket",
      "result" => ["ab"],
      "result_paths" => ["$['a']"],
      "selector" => "$ ['a']",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, newline between root and bracket" do
    testcase = %{
      "document" => %{"a" => "ab"},
      "name" => "whitespace, selectors, newline between root and bracket",
      "result" => ["ab"],
      "result_paths" => ["$['a']"],
      "selector" => "$\n['a']",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, tab between root and bracket" do
    testcase = %{
      "document" => %{"a" => "ab"},
      "name" => "whitespace, selectors, tab between root and bracket",
      "result" => ["ab"],
      "result_paths" => ["$['a']"],
      "selector" => "$\t['a']",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, return between root and bracket" do
    testcase = %{
      "document" => %{"a" => "ab"},
      "name" => "whitespace, selectors, return between root and bracket",
      "result" => ["ab"],
      "result_paths" => ["$['a']"],
      "selector" => "$\r['a']",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, space between bracket and bracket" do
    testcase = %{
      "document" => %{"a" => %{"b" => "ab"}},
      "name" => "whitespace, selectors, space between bracket and bracket",
      "result" => ["ab"],
      "result_paths" => ["$['a']['b']"],
      "selector" => "$['a'] ['b']",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, newline between bracket and bracket" do
    testcase = %{
      "document" => %{"a" => %{"b" => "ab"}},
      "name" => "whitespace, selectors, newline between bracket and bracket",
      "result" => ["ab"],
      "result_paths" => ["$['a']['b']"],
      "selector" => "$['a'] \n['b']",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, tab between bracket and bracket" do
    testcase = %{
      "document" => %{"a" => %{"b" => "ab"}},
      "name" => "whitespace, selectors, tab between bracket and bracket",
      "result" => ["ab"],
      "result_paths" => ["$['a']['b']"],
      "selector" => "$['a'] \t['b']",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, return between bracket and bracket" do
    testcase = %{
      "document" => %{"a" => %{"b" => "ab"}},
      "name" => "whitespace, selectors, return between bracket and bracket",
      "result" => ["ab"],
      "result_paths" => ["$['a']['b']"],
      "selector" => "$['a'] \r['b']",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, space between root and dot" do
    testcase = %{
      "document" => %{"a" => "ab"},
      "name" => "whitespace, selectors, space between root and dot",
      "result" => ["ab"],
      "result_paths" => ["$['a']"],
      "selector" => "$ .a",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, newline between root and dot" do
    testcase = %{
      "document" => %{"a" => "ab"},
      "name" => "whitespace, selectors, newline between root and dot",
      "result" => ["ab"],
      "result_paths" => ["$['a']"],
      "selector" => "$\n.a",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, tab between root and dot" do
    testcase = %{
      "document" => %{"a" => "ab"},
      "name" => "whitespace, selectors, tab between root and dot",
      "result" => ["ab"],
      "result_paths" => ["$['a']"],
      "selector" => "$\t.a",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, return between root and dot" do
    testcase = %{
      "document" => %{"a" => "ab"},
      "name" => "whitespace, selectors, return between root and dot",
      "result" => ["ab"],
      "result_paths" => ["$['a']"],
      "selector" => "$\r.a",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, space between dot and name" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "whitespace, selectors, space between dot and name",
      "selector" => "$. a",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "whitespace, selectors, newline between dot and name" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "whitespace, selectors, newline between dot and name",
      "selector" => "$.\na",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "whitespace, selectors, tab between dot and name" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "whitespace, selectors, tab between dot and name",
      "selector" => "$.\ta",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "whitespace, selectors, return between dot and name" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "whitespace, selectors, return between dot and name",
      "selector" => "$.\ra",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "whitespace, selectors, space between recursive descent and name" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "whitespace, selectors, space between recursive descent and name",
      "selector" => "$.. a",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "whitespace, selectors, newline between recursive descent and name" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "whitespace, selectors, newline between recursive descent and name",
      "selector" => "$..\na",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "whitespace, selectors, tab between recursive descent and name" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "whitespace, selectors, tab between recursive descent and name",
      "selector" => "$..\ta",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "whitespace, selectors, return between recursive descent and name" do
    testcase = %{
      "invalid_selector" => true,
      "name" => "whitespace, selectors, return between recursive descent and name",
      "selector" => "$..\ra",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    assert {:error, %JSONPath.Error{}} = JSONPath.evaluate(root, selector)
  end

  test "whitespace, selectors, space between bracket and selector" do
    testcase = %{
      "document" => %{"a" => "ab"},
      "name" => "whitespace, selectors, space between bracket and selector",
      "result" => ["ab"],
      "result_paths" => ["$['a']"],
      "selector" => "$[ 'a']",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, newline between bracket and selector" do
    testcase = %{
      "document" => %{"a" => "ab"},
      "name" => "whitespace, selectors, newline between bracket and selector",
      "result" => ["ab"],
      "result_paths" => ["$['a']"],
      "selector" => "$[\n'a']",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, tab between bracket and selector" do
    testcase = %{
      "document" => %{"a" => "ab"},
      "name" => "whitespace, selectors, tab between bracket and selector",
      "result" => ["ab"],
      "result_paths" => ["$['a']"],
      "selector" => "$[\t'a']",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, return between bracket and selector" do
    testcase = %{
      "document" => %{"a" => "ab"},
      "name" => "whitespace, selectors, return between bracket and selector",
      "result" => ["ab"],
      "result_paths" => ["$['a']"],
      "selector" => "$[\r'a']",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, space between selector and bracket" do
    testcase = %{
      "document" => %{"a" => "ab"},
      "name" => "whitespace, selectors, space between selector and bracket",
      "result" => ["ab"],
      "result_paths" => ["$['a']"],
      "selector" => "$['a' ]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, newline between selector and bracket" do
    testcase = %{
      "document" => %{"a" => "ab"},
      "name" => "whitespace, selectors, newline between selector and bracket",
      "result" => ["ab"],
      "result_paths" => ["$['a']"],
      "selector" => "$['a'\n]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, tab between selector and bracket" do
    testcase = %{
      "document" => %{"a" => "ab"},
      "name" => "whitespace, selectors, tab between selector and bracket",
      "result" => ["ab"],
      "result_paths" => ["$['a']"],
      "selector" => "$['a'\t]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, return between selector and bracket" do
    testcase = %{
      "document" => %{"a" => "ab"},
      "name" => "whitespace, selectors, return between selector and bracket",
      "result" => ["ab"],
      "result_paths" => ["$['a']"],
      "selector" => "$['a'\r]",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, space between selector and comma" do
    testcase = %{
      "document" => %{"a" => "ab", "b" => "bc"},
      "name" => "whitespace, selectors, space between selector and comma",
      "result" => ["ab", "bc"],
      "result_paths" => ["$['a']", "$['b']"],
      "selector" => "$['a' ,'b']",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, newline between selector and comma" do
    testcase = %{
      "document" => %{"a" => "ab", "b" => "bc"},
      "name" => "whitespace, selectors, newline between selector and comma",
      "result" => ["ab", "bc"],
      "result_paths" => ["$['a']", "$['b']"],
      "selector" => "$['a'\n,'b']",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, tab between selector and comma" do
    testcase = %{
      "document" => %{"a" => "ab", "b" => "bc"},
      "name" => "whitespace, selectors, tab between selector and comma",
      "result" => ["ab", "bc"],
      "result_paths" => ["$['a']", "$['b']"],
      "selector" => "$['a'\t,'b']",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, return between selector and comma" do
    testcase = %{
      "document" => %{"a" => "ab", "b" => "bc"},
      "name" => "whitespace, selectors, return between selector and comma",
      "result" => ["ab", "bc"],
      "result_paths" => ["$['a']", "$['b']"],
      "selector" => "$['a'\r,'b']",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, space between comma and selector" do
    testcase = %{
      "document" => %{"a" => "ab", "b" => "bc"},
      "name" => "whitespace, selectors, space between comma and selector",
      "result" => ["ab", "bc"],
      "result_paths" => ["$['a']", "$['b']"],
      "selector" => "$['a', 'b']",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, newline between comma and selector" do
    testcase = %{
      "document" => %{"a" => "ab", "b" => "bc"},
      "name" => "whitespace, selectors, newline between comma and selector",
      "result" => ["ab", "bc"],
      "result_paths" => ["$['a']", "$['b']"],
      "selector" => "$['a',\n'b']",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, tab between comma and selector" do
    testcase = %{
      "document" => %{"a" => "ab", "b" => "bc"},
      "name" => "whitespace, selectors, tab between comma and selector",
      "result" => ["ab", "bc"],
      "result_paths" => ["$['a']", "$['b']"],
      "selector" => "$['a',\t'b']",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, selectors, return between comma and selector" do
    testcase = %{
      "document" => %{"a" => "ab", "b" => "bc"},
      "name" => "whitespace, selectors, return between comma and selector",
      "result" => ["ab", "bc"],
      "result_paths" => ["$['a']", "$['b']"],
      "selector" => "$['a',\r'b']",
      "tags" => ["whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, slice, space between start and colon" do
    testcase = %{
      "document" => [1, 2, 3, 4, 5, 6],
      "name" => "whitespace, slice, space between start and colon",
      "result" => [2, 4],
      "result_paths" => ["$[1]", "$[3]"],
      "selector" => "$[1 :5:2]",
      "tags" => ["index", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, slice, newline between start and colon" do
    testcase = %{
      "document" => [1, 2, 3, 4, 5, 6],
      "name" => "whitespace, slice, newline between start and colon",
      "result" => [2, 4],
      "result_paths" => ["$[1]", "$[3]"],
      "selector" => "$[1\n:5:2]",
      "tags" => ["index", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, slice, tab between start and colon" do
    testcase = %{
      "document" => [1, 2, 3, 4, 5, 6],
      "name" => "whitespace, slice, tab between start and colon",
      "result" => [2, 4],
      "result_paths" => ["$[1]", "$[3]"],
      "selector" => "$[1\t:5:2]",
      "tags" => ["index", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, slice, return between start and colon" do
    testcase = %{
      "document" => [1, 2, 3, 4, 5, 6],
      "name" => "whitespace, slice, return between start and colon",
      "result" => [2, 4],
      "result_paths" => ["$[1]", "$[3]"],
      "selector" => "$[1\r:5:2]",
      "tags" => ["index", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, slice, space between colon and end" do
    testcase = %{
      "document" => [1, 2, 3, 4, 5, 6],
      "name" => "whitespace, slice, space between colon and end",
      "result" => [2, 4],
      "result_paths" => ["$[1]", "$[3]"],
      "selector" => "$[1: 5:2]",
      "tags" => ["index", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, slice, newline between colon and end" do
    testcase = %{
      "document" => [1, 2, 3, 4, 5, 6],
      "name" => "whitespace, slice, newline between colon and end",
      "result" => [2, 4],
      "result_paths" => ["$[1]", "$[3]"],
      "selector" => "$[1:\n5:2]",
      "tags" => ["index", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, slice, tab between colon and end" do
    testcase = %{
      "document" => [1, 2, 3, 4, 5, 6],
      "name" => "whitespace, slice, tab between colon and end",
      "result" => [2, 4],
      "result_paths" => ["$[1]", "$[3]"],
      "selector" => "$[1:\t5:2]",
      "tags" => ["index", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, slice, return between colon and end" do
    testcase = %{
      "document" => [1, 2, 3, 4, 5, 6],
      "name" => "whitespace, slice, return between colon and end",
      "result" => [2, 4],
      "result_paths" => ["$[1]", "$[3]"],
      "selector" => "$[1:\r5:2]",
      "tags" => ["index", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, slice, space between end and colon" do
    testcase = %{
      "document" => [1, 2, 3, 4, 5, 6],
      "name" => "whitespace, slice, space between end and colon",
      "result" => [2, 4],
      "result_paths" => ["$[1]", "$[3]"],
      "selector" => "$[1:5 :2]",
      "tags" => ["index", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, slice, newline between end and colon" do
    testcase = %{
      "document" => [1, 2, 3, 4, 5, 6],
      "name" => "whitespace, slice, newline between end and colon",
      "result" => [2, 4],
      "result_paths" => ["$[1]", "$[3]"],
      "selector" => "$[1:5\n:2]",
      "tags" => ["index", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, slice, tab between end and colon" do
    testcase = %{
      "document" => [1, 2, 3, 4, 5, 6],
      "name" => "whitespace, slice, tab between end and colon",
      "result" => [2, 4],
      "result_paths" => ["$[1]", "$[3]"],
      "selector" => "$[1:5\t:2]",
      "tags" => ["index", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, slice, return between end and colon" do
    testcase = %{
      "document" => [1, 2, 3, 4, 5, 6],
      "name" => "whitespace, slice, return between end and colon",
      "result" => [2, 4],
      "result_paths" => ["$[1]", "$[3]"],
      "selector" => "$[1:5\r:2]",
      "tags" => ["index", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, slice, space between colon and step" do
    testcase = %{
      "document" => [1, 2, 3, 4, 5, 6],
      "name" => "whitespace, slice, space between colon and step",
      "result" => [2, 4],
      "result_paths" => ["$[1]", "$[3]"],
      "selector" => "$[1:5: 2]",
      "tags" => ["index", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, slice, newline between colon and step" do
    testcase = %{
      "document" => [1, 2, 3, 4, 5, 6],
      "name" => "whitespace, slice, newline between colon and step",
      "result" => [2, 4],
      "result_paths" => ["$[1]", "$[3]"],
      "selector" => "$[1:5:\n2]",
      "tags" => ["index", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, slice, tab between colon and step" do
    testcase = %{
      "document" => [1, 2, 3, 4, 5, 6],
      "name" => "whitespace, slice, tab between colon and step",
      "result" => [2, 4],
      "result_paths" => ["$[1]", "$[3]"],
      "selector" => "$[1:5:\t2]",
      "tags" => ["index", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end

  test "whitespace, slice, return between colon and step" do
    testcase = %{
      "document" => [1, 2, 3, 4, 5, 6],
      "name" => "whitespace, slice, return between colon and step",
      "result" => [2, 4],
      "result_paths" => ["$[1]", "$[3]"],
      "selector" => "$[1:5:\r2]",
      "tags" => ["index", "whitespace"]
    }

    selector = testcase["selector"]
    root = testcase["document"]

    %{"result" => result, "result_paths" => result_path} = testcase

    # Only one possible result
    {:ok, value} = JSONPath.evaluate(root, selector)

    assert value == result,
           "for query #{selector} and root #{inspect(root)}, expected: #{inspect(result)}, got: #{inspect(value)}"

    {:ok, paths} = JSONPath.evaluate(root, selector, :paths)

    assert paths == result_path,
           "for query #{selector} and root #{inspect(root)}, expected paths: #{inspect(result_path)}, got: #{inspect(paths)}"
  end
end
