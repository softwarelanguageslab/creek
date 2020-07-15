defmodule Creek.BalanceExample do
  use Creek
  # meta(Merge)
  # runtime_meta(Creek.Runtime.Meta.Default)

  defdag test(src, snk) do
    src
    ~> balance(2)
    ~> (map(fn x ->
          IO.puts("Left")
          x
        end) |||
          map(fn x ->
            IO.puts("Right")
            x
          end))
    ~> merge(2)
    ~> snk
  end

  @spec main :: any
  def main() do
    source = Creek.Source.list([1, 9, 2, 8, 3, 7, 4, 6, 5])

    ivar = Ivar.new()
    sink = Creek.Sink.all(ivar)

    Creek.Runtime.run(test(), [src: source, snk: sink], dot: true)

    ivar
    |> Ivar.get()
    |> IO.inspect()
  end
end
