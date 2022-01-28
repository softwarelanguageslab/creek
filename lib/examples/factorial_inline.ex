defmodule Creek.FactorialInline do
  use Creek
  # meta(Merge)
  # execution(Logging)

  @spec main :: any
  def main() do
    d =
      dag test(src, snk) do
        src
        ~> transform(1, fn v, acc -> {acc * v, acc * v} end)
        ~> snk
      end

    source = Creek.Source.range(1, 30)
    ivar = Ivar.new()
    sink = Creek.Sink.all(ivar)
    Creek.Runtime.run(d, [src: source, snk: sink], dot: true)

    ivar
    |> Ivar.get()
    |> IO.inspect()
  end
end
