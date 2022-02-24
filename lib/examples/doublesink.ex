defmodule Creek.DoubleSink do
  @moduledoc """
  An example of using the default meta-level. That is to say, each value will be propagated through the meta-level, but the meta-level will not actually do anything.
  """
  use Creek

  defdag test(src, snk) do
    let s(as map(fn x -> x end))
    src ~> dup ~> (s.() ~> snk ||| s.() ~> snk)
  end

  def main() do
    s1 = Creek.Source.range(0, 10)
    ivar = Ivar.new()
    sink = Creek.Sink.all(ivar)

    Creek.Runtime.run(test(), [src: s1, snk: sink], dot: true)

    ivar
    |> Ivar.get()
  end
end
