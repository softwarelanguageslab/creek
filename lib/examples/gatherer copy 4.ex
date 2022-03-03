defmodule Creek.Gatherer4 do
  use Creek
  # meta(Merge)
  # execution(Debugging)

  defdag test(src, snk) do
    src
    ~> snk
  end

  def main() do

    s1 = Creek.Source.range(1000, :infinity, 1, 1000)
    s2 = Creek.Source.range(0, :infinity, 1, 1000)

    spawn(fn ->
      Process.monitor(s2)
      receive do
        m ->
          IO.inspect m, label: "Monitor"
      end
    end)

    gatherer = Creek.Source.gatherer()
    snk = Creek.Sink.each(fn x -> IO.puts("Value: #{inspect(x)}") end)
    deploy(test, src: gatherer, snk: snk)

    deploy(test, src: s1, snk: gatherer)
    deploy(test, src: s2, snk: gatherer)
    Process.register(s1, :s1)
    Process.register(s2, :s2)
    Process.register(gatherer, :gatherer)
    Process.register(snk, :snk)

    IO.inspect s1, label: "s1"
    IO.inspect s2, label: "s2"
    IO.inspect gatherer, label: "gatherer"
    IO.inspect snk, label: "snk"
  end

end
