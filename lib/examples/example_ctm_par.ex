defmodule Creek.ExampleCtmPar do
  @moduledoc """
  An example of using compile-time and run-time meta.
  The DAG consists of three map operators, and they are merged at compiletime into a single map operator.
  The DAG is executed with pull semantics.
  """
  use Creek
  structure(Parallelize)

  # Bench with
  fragment mapper as map(
                       fn x ->
                         IO.puts(x)
                         Process.sleep(5000)
                         x
                       end,
                       parallel: 5
                     )

  defdag test(src, snk) do
    src ~> mapper() ~> snk
  end

  @spec main :: any
  def main() do
    source = Creek.Source.list([1, 2, 3, 4, 5, 6, 7, 8])

    ivar = Ivar.new()
    sink = Creek.Sink.all(ivar)

    Creek.Runtime.run(test(), [src: source, snk: sink], dot: true)

    ivar
    |> Ivar.get()
    |> IO.inspect()
  end
end
