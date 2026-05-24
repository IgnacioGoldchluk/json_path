defmodule JSONPath.Eval.Slice do
  @moduledoc false
  # This mess deserves its own module

  @doc """
  Runs a slice of the given start, stop and step arguments
  """
  @spec apply(list(), integer(), integer(), integer()) :: list()
  def apply(_array, _start, _stop, 0), do: []
  def apply([], _start, _stop, _step), do: []

  def apply(array, start, stop, step) do
    len = length(array)

    {start, stop} = normalise(start, stop, step, len)

    array
    |> Enum.with_index()
    |> Enum.filter(fn {_v, i} -> in_slice?(i, start, stop, step) end)
    |> Enum.map(fn {v, _i} -> v end)
    |> then(fn selected ->
      if step < 0, do: Enum.reverse(selected), else: selected
    end)
  end

  defp normalise(start, stop, step, len) when step > 0 do
    start =
      case start do
        nil -> 0
        s when s < 0 -> max(len + s, 0)
        s -> min(s, len)
      end

    stop =
      case stop do
        nil -> len
        s when s < 0 -> max(len + s, 0)
        s -> min(s, len)
      end

    {start, stop}
  end

  defp normalise(start, stop, step, len) when step < 0 do
    start =
      case start do
        nil -> len - 1
        s when s < 0 -> len + s
        s -> min(s, len - 1)
      end

    stop =
      case stop do
        nil -> -1
        s when s < 0 -> len + s
        s -> s
      end

    {start, stop}
  end

  defp in_slice?(i, start, stop, step) when step > 0 do
    i >= start and i < stop and rem(i - start, step) == 0
  end

  defp in_slice?(i, start, stop, step) when step < 0 do
    i <= start and i > stop and rem(start - i, -step) == 0
  end
end
