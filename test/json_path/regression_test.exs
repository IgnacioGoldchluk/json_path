defmodule JSONPath.RegressionTest do
  use ExUnit.Case

  # Cases that fail on at least one Elixir implementation
  # from https://cburgmer.github.io/json-path-comparison/

  test "array slice on object" do
    assert {:ok, []} == JSONPath.values(%{":" => 42}, "$[1:3]")
  end

  test "slice with large number for end and negative step" do
    query = "$[2:-113667776004:-1]"
    root = ["first", "second", "third", "forth", "fifth"]
    assert {:ok, ["third", "second", "first"]} == JSONPath.values(root, query)
  end

  test "slice with large number for start end negative step" do
    query = "$[113667776004:2:-1]"
    root = ["first", "second", "third", "forth", "fifth"]

    assert {:ok, ["fifth", "forth"]} == JSONPath.values(root, query)
  end

  test "slice with negative step" do
    query = "$[3:0:-2]"
    root = ["first", "second", "third", "forth", "fifth"]
    assert {:ok, ["forth", "second"]} == JSONPath.values(root, query)
  end

  test "slice with negative step on partially overlapping array" do
    query = "$[7:3:-1]"
    root = ["first", "second", "third", "forth", "fifth"]

    assert {:ok, ["fifth"]} == JSONPath.values(root, query)
  end

  test "slice with negative step only" do
    query = "$[::-2]"
    root = ["first", "second", "third", "forth", "fifth"]

    assert {:ok, ["fifth", "third", "first"]} == JSONPath.values(root, query)
  end

  test "slice with open end and negative step" do
    query = "$[3::-1]"
    root = ["first", "second", "third", "forth", "fifth"]

    assert {:ok, ["forth", "third", "second", "first"]} == JSONPath.values(root, query)
  end

  test "slice with open start and negative step" do
    query = "$[:2:-1]"
    root = ["first", "second", "third", "forth", "fifth"]

    assert {:ok, ["fifth", "forth"]} == JSONPath.values(root, query)
  end

  test "slice with range of 0" do
    query = "$[0:0]"
    root = ["first", "second"]

    assert {:ok, []} == JSONPath.values(root, query)
  end

  test "notation with number on string" do
    query = "$[0]"
    root = "Hello"

    assert {:ok, []} == JSONPath.values(root, query)
  end

  test "notation with quoted escaped backslash" do
    query = "$['\\\\']"
    root = %{"\\" => "value"}

    assert {:ok, ["value"]} == JSONPath.values(root, query)
  end

  test "notation with quoted escaped single quote" do
    query = "$['\\\'']"
    root = %{"'" => "value"}
    assert {:ok, ["value"]} == JSONPath.values(root, query)
  end

  test "expression with equals null" do
    query = "$[?(@.key==null)]"

    root = [
      %{"some" => "value"},
      %{"key" => false},
      %{"key" => -1},
      %{"key" => nil},
      %{"key" => 0},
      %{"key" => []},
      %{"key" => %{}}
    ]

    assert {:ok, [%{"key" => nil}]} == JSONPath.values(root, query)
  end

  test "expression with equals with root reference" do
    query = "$.items[?(@.key==$.value)]"
    root = %{"items" => [%{"key" => 10}, %{"key" => 42}, %{"key" => 50}], "value" => 42}

    assert {:ok, [%{"key" => 42}]} == JSONPath.values(root, query)
  end

  test "expression with negation and equals" do
    query = "$[?(!(@.key==42))]"
    root = [%{"key" => 1}, %{"key" => 42}, %{"key" => nil}]

    assert {:ok, [%{"key" => 1}, %{"key" => nil}]} == JSONPath.values(root, query)
  end

  test "expression with value after dot notation with wildcard on array of objects" do
    query = "$.*[?(@.key)]"
    root = [%{"some" => "some value"}, %{"key" => "value"}]
    assert {:ok, []} == JSONPath.values(root, query)
  end

  test "expression with value after recursive descent" do
    query = "$..[?(@.id)]"

    root = %{
      "id" => 2,
      "more" => [
        %{"id" => 2},
        %{"more" => %{"id" => 2}},
        %{"id" => %{"id" => 2}},
        [%{"id" => 2}]
      ]
    }

    expected = [%{"id" => 2}, %{"id" => %{"id" => 2}}, %{"id" => 2}, %{"id" => 2}, %{"id" => 2}]

    assert {:ok, expected} == JSONPath.values(root, query)
  end

  test "keys after recursive descent" do
    query = "$..['c','d']"

    root = [
      %{"c" => "cc1", "d" => "dd1", "e" => "ee1"},
      %{"c" => "cc2", "child" => %{"d" => "dd2"}},
      %{"c" => "cc3"},
      %{"d" => "dd4"},
      %{"child" => %{"c" => "cc5"}}
    ]

    assert {:ok, ["cc1", "dd1", "cc2", "dd2", "cc3", "dd4", "cc5"]} ==
             JSONPath.values(root, query)
  end
end
