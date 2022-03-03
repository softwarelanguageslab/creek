defmodule Creek.Factorial do
  use Creek
  # meta(Merge)
  # execution(Debugging)

  defdag test(src, snk) do
    src
    ~> transform(1, fn v, acc -> {acc * v, acc * v} end)
    ~> snk
  end

  def main() do
    source = Creek.Source.range(1, 3, 1, 1000)
    ivar = Ivar.new()
    sink = Creek.Sink.all(ivar)
    Creek.Runtime.run(test(), [src: source, snk: sink], dot: true)

    ivar
    |> Ivar.get()
    |> IO.inspect()
  end
end
