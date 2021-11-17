defmodule Creek.StartWith do
  use Creek
  # meta(Merge)
  # execution(IdentityMeta)

  defdag debug(src1, src2, snk) do
    src1
    ~> merge(src2)
    ~> map(fn x -> IO.puts "Value!" end)
    ~> snk
  end

  @spec main :: any
  def main() do
    subject = Creek.Source.replay_subject()
    sink = Creek.Sink.ignore(self())
    deploy(debug, [src: subject, snk: sink], [])


    for i <- 1..10 do
      Creek.Source.ReplaySubject.next(subject, i)
    end

    receive do
      :done ->
        IO.puts("Done")
    end
  end
end
