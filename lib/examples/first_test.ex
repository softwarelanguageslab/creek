defmodule Creek.FirstExample do
  use Creek
  # meta(Merge)
  # execution(Debugging)

  defdag test(src, snk) do
    src
    ~> map(fn x -> IO.puts "Value: #{x}"; x end)
    ~> snk
  end

  @spec main :: any
  def main() do
    source = Creek.Source.range(1, :infinity, 1, 1000)
    sink = Creek.Sink.first(nil)
    Creek.Runtime.run(test(), [src: source, snk: sink], dot: true)

    Process.sleep(10000)
  end
end
