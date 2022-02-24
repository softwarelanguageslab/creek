defmodule Creek.DebugExample do
  use Creek
  # meta(Merge)
  execution(Debugging)

  defdag test(src, src2, snk) do
    (src ||| src2)
    ~> merge()
    ~> transform(1, fn v, acc -> {acc * v, acc * v} end)
    ~> snk
  end

  @spec main :: any
  def main() do
    source = Creek.Source.range(1, 3, 1, 1000)
    source2 = Creek.Source.range(10, 11000, 1, 1000)
    ivar = Ivar.new()
    sink = Creek.Sink.all(ivar)
    Creek.Runtime.run(test(), [src: source, src2: source2, snk: sink], dot: true)

    ivar
    |> Ivar.get()
    |> IO.inspect()
  end
end
