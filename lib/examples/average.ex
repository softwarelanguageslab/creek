defmodule Creek.Average do
  use Creek
  # meta(Merge)
  # runtime_meta(Creek.Runtime.Meta.Default)

  defdag test(src, snk) do
    src
    ~> average()
    ~> snk
  end

  @spec main :: any
  def main() do
    source = Creek.Source.range(1, 2)
    ivar = Ivar.new()
    sink = Creek.Sink.all(ivar)
    Creek.Runtime.run(test(), [src: source, snk: sink], dot: true)

    ivar
    |> Ivar.get()
    |> IO.inspect()
  end
end
