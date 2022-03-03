defmodule Creek.Average do
  use Creek

  defdag test(src, snk) do
    src
    ~> average()
    ~> snk
  end

  @spec main :: any
  def main() do
    source = Creek.Source.list([1.0, 1.1, 1.2])
    ivar = Ivar.new()
    sink = Creek.Sink.all(ivar)
    Creek.Runtime.run(test(), [src: source, snk: sink], dot: true)

    ivar
    |> Ivar.get()
    |> IO.inspect()
  end
end
