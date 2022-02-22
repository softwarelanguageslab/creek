defmodule Creek.ReplaySubjectTest do
  use Creek
  # meta(Merge)
  # execution(IdentityMeta)

  defdag printer(src, snk) do
    src
    ~> map(fn x -> IO.puts("Value: #{inspect(x)}") end)
    ~> snk
  end

  @spec main :: any
  def main() do
    sub = Creek.Source.replay_subject()
    snk = Creek.Sink.ignore(self())
    deploy(printer, src: sub, snk: snk)

    for i <- 1..10 do
      Creek.Source.Subject.next(sub, i)
    end

    Process.sleep(5000)
    snk = Creek.Sink.ignore(self())
    deploy(printer, src: sub, snk: snk)

    Creek.Source.ReplaySubject.complete(sub)

    receive do
      :done ->
        IO.puts("Done")
    end

    receive do
      :done ->
        IO.puts("Done")
    end
  end
end
