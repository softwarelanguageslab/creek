defmodule Creek.Window do
  @moduledoc """
  An example of using the default meta-level. That is to say, each value will be propagated through the meta-level, but the meta-level will not actually do anything.
  """
  use Creek

  defdag test(src1, src2, snk) do
    (src1 ||| src2)
    ~> zipRight()
    ~> map(fn {x, y} -> y end)
    ~> snk
  end

  @spec main :: any
  def main() do
    s1 = Creek.Source.delay(10000, :delayed_value)
    s2 = Creek.Source.range(0, :inifinity)

    ivar = Ivar.new()
    sink = Creek.Sink.all(ivar)

    Creek.Runtime.run(test(), [src1: s1, src2: s2, snk: sink], dot: true)

    ivar
    |> Ivar.get()
  end
end
