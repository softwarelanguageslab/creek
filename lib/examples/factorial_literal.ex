defmodule Creek.Factorial2 do
  use Creek
  # meta(Merge)
  execution(Logging)

  defdag test(src, snk) do
    src
    ~> transform(1, fn v, acc -> {acc * v, acc * v} end)
    ~> snk
  end

  @spec main :: any
  def main() do
    source = Creek.Source.range(1, 30, 1, 1000)
    ivar = Ivar.new()
    sink = Creek.Sink.all(ivar)
    Creek.Runtime.run(test(), [src: source, snk: sink], dot: true)

    ivar
    |> Ivar.get()
    |> IO.inspect()
  end
end
