defmodule Creek.StartWith do
  use Creek
  # meta(Merge)
  # execution(IdentityMeta)

  defdag debug(src, snk, label) do
    src
    ~> map(fn x -> IO.puts("#{label}: #{x}") end)
    ~> snk
  end

  @spec main :: any
  def main() do
    subject = Creek.Source.replay_subject()
    sink = Creek.Sink.ignore(self())

    for i <- 1..10 do
      Creek.Source.ReplaySubject.next(subject, i)
    end

    deploy(debug, [src: subject, snk: sink, label: "test"], [])
    Process.sleep(1000)
    deploy(debug, [src: subject, snk: sink, label: "test2"], [])
    Process.sleep(1000)
    deploy(debug, [src: subject, snk: sink, label: "test3"], [])
    Process.sleep(1000)
    deploy(debug, [src: subject, snk: sink, label: "test4"], [])
    Process.sleep(1000)
    deploy(debug, [src: subject, snk: sink, label: "test5"], [])
    Process.sleep(1000)
    Creek.Source.ReplaySubject.complete(subject)

    receive do
      :done ->
        IO.puts("Done")
    end
  end
end
