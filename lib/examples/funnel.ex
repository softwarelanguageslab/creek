defmodule Creek.Funnel do
  use Creek
  # meta(Merge)
  # execution(IdentityMeta)

  defdag send_to_funnel(src, snk) do
    src
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
    sub = Creek.Source.subj()
    sink = Creek.Sink.ignore(self())

    IO.inspect(sub, label: "sub")
    # Deploy a DAG to print out all the values coming from
    # the subject.
    deploy(print_funnel, src: sub.source, snk: sink)

    for i <- 1..10 do
      src = Creek.Source.single(i)
      deploy(send_to_funnel, src: src, snk: sub.sink.())
    end

    receive do
      :done ->
        IO.puts("Done")
    end
  end
end
