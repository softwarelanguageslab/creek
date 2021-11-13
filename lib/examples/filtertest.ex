defmodule Creek.FilterTest do
  @moduledoc """
  An example of using the default meta-level. That is to say, each value will be propagated through the meta-level, but the meta-level will not actually do anything.
  """
  use Creek

  defdag test(src, snk) do
    src ~> filter(fn x -> x > 5 end) ~> snk
  end

  @spec main :: any
  def main() do
    s = Creek.Source.range(0, 10)

    ivar = Ivar.new()
    sink = Creek.Sink.all(ivar)

    Creek.Runtime.run(test(), [src: s, snk: sink], dot: true)

    ivar
    |> Ivar.get()
  end
end
