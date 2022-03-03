defmodule M do
  use Creek

  defdag test(src, snk) do
    src
    ~> map(fn x -> IO.inspect x; x end)
    ~> snk
  end
end

defmodule TestModuleDag do
  use Creek
  def main() do
    source = Creek.Source.range(1, 100)
    sink = Creek.Sink.ignore(nil)
    deploy_module(M, :test, src: source, snk: sink)
    Process.sleep(10000)
  end
end
