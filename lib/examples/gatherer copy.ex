defmodule Creek.Gatherer2 do
  use Creek
  # meta(Merge)
  # execution(IdentityMeta)

  defdag send_to_gatherer(src, snk) do
    src
    ~> snk
  end

  defdag print_gatherer(src, snk) do
    src
    ~> map(fn x ->
      IO.puts(x)
      x
    end)
    ~> snk
  end

  @spec main :: any
  def main() do
    gatherer = Creek.Source.gatherer()
    sink = Creek.Sink.ignore(self())

    # Deploy a DAG to print out all the values coming from
    # the subject.
    deploy(print_gatherer, src: gatherer, snk: sink)

    Process.sleep(3000)

    spawn(fn ->
      for i <- 1..10 do
        spawn(fn ->
          src = Creek.Source.range(1, :infinity, 1, 1000)
          deploy(send_to_gatherer, src: src, snk: gatherer)
        end)
      end
    end)

    Process.sleep(2000)
    Creek.Source.Gatherer.complete(gatherer)
    receive do
      :done ->
        IO.puts("Done")
    end
  end
end
