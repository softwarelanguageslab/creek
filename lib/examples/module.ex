defmodule M do
  use Creek
  execution(SmartPull)

  defdag test(src, snk) do
    src
    ~> map(fn x -> IO.inspect x; x end)
    ~> snk
  end
end

defmodule TestModuleDag do
  use Creek
  def main() do
    source = Creek.Source.range(1, 5, 1, 5000)
    sink = Creek.Sink.first(nil)
    deploy_module(M, :test, src: source, snk: sink)
    Process.sleep(10000)
  end
end
