defmodule Creek.ExampleRtmPull do
  @moduledoc """
  An example of changing the runtime semantics of the DAG to pull-based instead of the default push-based semantics.

  """
  use Creek
  execution(SmartPull)

  fragment mapper as filter(fn y -> rem(y, 2) == 0 end)
                     ~> map(fn x ->
                       x
                     end)

  defdag test(src, snk) do
    src ~> mapper() ~> snk
  end

  @spec main :: any
  def main() do
    source = Creek.Source.list([1, 2, 3, 4, 5, 6])

    ivar = Ivar.new()
    sink = Creek.Sink.all(ivar)

    # Creek.Runtime.run(test(), [src: source, snk: sink], dot: true, debug: true)
    Creek.Runtime.run(test(), [src: source, snk: sink], dot: true)

    ivar
    |> Ivar.get()
    |> IO.inspect()
  end
end
