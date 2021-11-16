defmodule Creek.Multiplier do
  use Creek
  # meta(Merge)
  # execution(IdentityMeta)

  defdag multiplier(thesource, thesink, a, b) do
    thesource
    ~> map(fn x -> x + a end)
    ~> map(fn x -> x + b end)
    ~> thesink
  end

  @spec main :: any
  def main() do
    source = Creek.Source.range(1, 10)
    ivar = Ivar.new()
    sink = Creek.Sink.all(ivar)

    deploy(multiplier, [thesource: source, thesink: sink, a: 1, b: 2], dot: true)

    ivar
    |> Ivar.get()
    |> IO.inspect()

    nil
  end
end
