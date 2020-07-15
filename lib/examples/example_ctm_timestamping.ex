defmodule Creek.ExampleCtmTs do
  @moduledoc """
  An example of using compile-time meta.
  An operator is injected before each operator to add a timestamp value.
  """
  use Creek
  structure(Timestamp)

  fragment mapper(as map(fn x -> x + 1 end))

  defdag test(src, snk) do
    src ~> dup() ~> (mapper ||| mapper) ~> merge ~> snk
  end

  @spec main :: any
  def main() do
    source = Creek.Source.list([1, 2, 3, 4, 5, 6, 7, 8, 9])

    ivar = Ivar.new()
    sink = Creek.Sink.all(ivar)

    Creek.Runtime.run(test(), [src: source, snk: sink], dot: true)

    ivar
    |> Ivar.get()
    |> IO.inspect()
  end
end
