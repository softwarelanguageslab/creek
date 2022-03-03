defmodule Creek.Distri do
  use Creek
  # meta(Merge)
  # execution(Debugging)

  defdag test(src, snk) do
    src
    ~> map(fn x -> IO.puts x ; x end)
    ~> snk
  end

  @spec main :: any
  def main() do
    source = deploy_remote_source()
    sink = deploy_remote_sink()
    Creek.Runtime.run(test(), [src: source, snk: sink])

    Process.sleep(50000)
  end

  def deploy_remote_source() do
    remote = hd(Node.list())
    sender = self()

    # Deploy the remote source.
    Node.spawn(remote, fn ->
      source = Creek.Source.range(0, :infinity, 1000, 500)
      send(sender, source)
    end)

    # Wait for the pid of the remote source.
    remote_source =
      receive do
        pid ->
          pid
      end

    remote_source
  end
  def deploy_remote_sink() do
    remote = hd(tl(Node.list()))
    sender = self()

    # Deploy the remote source.
    Node.spawn(remote, fn ->
      sink = Creek.Sink.each(fn x -> IO.puts "Got value: #{inspect x}" end)
      send(sender, sink)
    end)

    # Wait for the pid of the remote source.
    remote_sink =
      receive do
        pid ->
          pid
      end

      remote_sink
  end

end
