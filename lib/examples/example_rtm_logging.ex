defmodule Creek.ExampleRtmLogging do
  use Creek
  execution(Logging)

  fragment mapper as filter(fn {x, y} -> rem(y, 2) == 0 end)
                     ~> map(fn {x, y} ->
                       x + y
                     end)

  defdag logged_dag(left, right, snk) do
    (left ||| right)
    ~> zip()
    ~> mapper
    ~> snk
  end

  def main() do
    l = Creek.Source.list([1, 2, 3, 4, 5, 6])
    r = Creek.Source.list([10, 20, 30, 40, 50, 60])

    ivar = Ivar.new()
    sink = Creek.Sink.all(ivar)

    # Creek.Runtime.run(test(), [src: source, snk: sink], dot: true, debug: true)
    Creek.Runtime.run(logged_dag(), [left: l, right: r, snk: sink], dot: true)

    ivar
    |> Ivar.get()
    |> IO.inspect()
  end
end
