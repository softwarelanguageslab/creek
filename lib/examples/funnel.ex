defmodule Creek.Funnel do
  use Creek
  # meta(Merge)
  # execution(IdentityMeta)

  defdag send_to_funnel(src, snk) do
    src
    ~> map(fn x ->
      IO.puts(x)
      x
    end)
    ~> snk
  end

  defdag print_funnel(src, snk) do
    src
    ~> map(fn x -> IO.puts("Value: #{inspect(x)}") end)
    ~> take(10)
    ~> snk
  end

  @spec main :: any
  def main() do
    subject = Creek.Source.subject()
    funnel = Creek.Sink.funnel(subject, "this one")

    sink = Creek.Sink.ignore(self())

    deploy(print_funnel, [src: subject, snk: sink], [])

    for i <- 1..10 do
      src = Creek.Source.single(i)
      deploy(send_to_funnel, [src: src, snk: funnel], [])
    end

    receive do
      :done ->
        IO.puts("Done")
    end
  end
end
