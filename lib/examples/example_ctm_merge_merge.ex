defmodule Creek.ExampleCtm do
  @moduledoc """
  An example of using consecutive compile-time meta-operations.

  First all the filter operators are merged and then all the map operators are merged.
  """
  use Creek
  structure(MergeFilter, MergeMap)

  fragment mapper as map(fn x -> x end)
                     ~> map(fn x -> x end)
                     ~> map(fn x -> x end)
                     ~> filter(fn _ -> true end)
                     ~> filter(fn _ -> true end)
                     ~> filter(fn _ -> true end)

  defdag test(src, snk) do
    src ~> dup() ~> (mapper() ||| mapper()) ~> merge() ~> snk
  end

  @spec main :: any
  def main() do
    source = Creek.Source.list([1, 2, 3, 4])

    ivar = Ivar.new()
    sink = Creek.Sink.all(ivar)

    Creek.Runtime.run(test(), [src: source, snk: sink], dot: true)

    ivar
    |> Ivar.get()
    |> IO.inspect()
  end
end
