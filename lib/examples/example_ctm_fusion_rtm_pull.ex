defmodule Creek.ExampleCtmRtm do
  @moduledoc """
  An example of using compile-time and run-time meta.
  The DAG consists of three map operators, and they are merged at compiletime into a single map operator.
  The DAG is executed with pull semantics.
  """
  use Creek
  structure(Merge)
  execution(Pull)

  # Bench with
  fragment mapper as map(fn x -> x end)
                     ~> map(fn x -> x end)
                     ~> map(fn x -> x end)

  defdag test(src, snk) do
    src ~> mapper() ~> snk
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
