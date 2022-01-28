defmodule Creek.MetaArg do
  use Creek
  # meta(Merge)
  execution(Debugging2)

  defdag test(src, src2, snk) do
    (src ||| src2)
    ~> merge()
    ~> map(fn x -> x end)
    ~> snk
  end

  @spec main :: any
  def main() do
    source = Creek.Source.range(1, :infinity, 1, 5000)
    source2 = Creek.Source.range(6, :infinity, 1, 5000)

    injector = Creek.Debugger.subject()
    snk = Creek.Debugger.sink()

    ivar = Ivar.new()
    sink = Creek.Sink.all(ivar)
    Creek.Runtime.run(test(), [src: source, src2: source2, snk: sink], meta_sink: [sock: snk], meta_in: injector)

    ivar
    |> Ivar.get()
    |> IO.inspect()
  end
end
