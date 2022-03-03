defmodule Creek.GatherDistri do
  use Creek
  # meta(Merge)
  # execution(Debugging)

  defdag test(src, snk) do
    src
    ~> snk
  end

  def main() do
    first = hd(Node.list())
    second = hd(tl(Node.list()))

    gatherer = Creek.Source.gatherer()
    snk = Creek.Sink.each(fn x -> IO.puts("Value: #{inspect(x)}") end)
    deploy(test, src: gatherer, snk: snk)

    deploy_remote(first, gatherer)
    deploy_remote(second, gatherer)
    Process.sleep(50000)
  end

  def deploy_remote(remote, snk) do
    Node.spawn(remote, fn ->
      source = Creek.Source.range(0, :infinity, 1000, 500)

      deploy(test, src: source, snk: snk)
    end)
  end
end
