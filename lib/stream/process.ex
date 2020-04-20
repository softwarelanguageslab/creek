defmodule Creek.Stream.Process do
  require Logger

  # -----------------------------------------------------------------------------
  # Source

  def source(node, ds) do
    # Logger.debug("#{inspect(self())} Source running: #{inspect(node)}")
    srloop(node, ds)
  end

  defp srloop(node, ds) do
    receive do
      {:add_downstream, d} ->
        srloop(node, MapSet.put(ds, d))

      {:subscribe, _d} ->
        node.subscribe.(node.argument, ds)
        srloop(node, ds)

      :dispose ->
        Logger.warn("#{inspect(self())} Source stopping: #{inspect(node)}")
        :stop

      {:send, to, payload} ->
        send(to, payload)
        srloop(node, ds)

      m ->
        IO.puts("Source did not understand: #{inspect(m)}")
    end
  end

  # -----------------------------------------------------------------------------
  # Process

  def process(node, ds, us) do
    # Logger.debug("#{inspect(self())} Process running: #{inspect(node)}")
    ploop(node, ds, us)
  end

  defp ploop(node, ds, us) do
    receive do
      {:add_downstream, d} ->
        ploop(node, MapSet.put(ds, d), us)

      {:add_upstream, u} ->
        ploop(node, ds, MapSet.put(us, u))

      {:subscribe, _who} ->
        for u <- us, do: send(u, {:subscribe, self()})
        ploop(node, ds, us)

      {:next, value} ->
        node.next.(node.argument, value, ds)
        ploop(node, ds, us)

      {:complete, upstream} ->
        node.complete.(upstream, us, ds)
        us = MapSet.delete(us, upstream)
        ploop(node, ds, us)

      :dispose ->
        for u <- us, do: send(u, :dispose)
        Logger.warn("#{inspect(self())} Process stopping: #{inspect(node)}")
        :stop

      {:send, to, payload} ->
        send(to, payload)
        ploop(node, ds, us)

      m ->
        IO.puts("Process did not understand: #{inspect(m)}")
        ploop(node, ds, us)
    end
  end

  # -----------------------------------------------------------------------------
  # Sinks

  def sink(node, ivar, source) do
    # Logger.debug("#{inspect(self())} Sink running #{inspect(node)} #{inspect(ivar)} #{inspect(source)}")
    sloop(node, ivar, source, node.state, [], [])
  end

  defp sloop(node, ivar, source, state, downstream, upstream) do
    receive do
      :init ->
        send(source, {:subscribe, self()})
        sloop(node, ivar, source, state, downstream, upstream)

      {:subscribe, _who} ->
        sloop(node, ivar, source, state, downstream, upstream)

      {:next, value} ->
        state = node.next.(node, value, state, downstream)

        case state do
          {:continue, state} ->
            sloop(node, ivar, source, state, downstream, upstream)

          {:done, state} ->
            Ivar.put(ivar, state)
            send(source, :dispose)
            Logger.warn("#{inspect(self())} Sink stopping: #{inspect(node)}")
            :stop
        end

      {:complete, _from} ->
        result = node.complete.(state, downstream)

        case result do
          {:done, state} ->
            Ivar.put(ivar, state)
            send(source, :dispose)
            Logger.warn("#{inspect(self())} Sink stopping: #{inspect(node)}")
            :stop

          {:continue, state} ->
            for d <- downstream, do: send(d, {:complete, self()})
            sloop(node, ivar, source, state, downstream, upstream)
        end

      {:add_downstream, d} ->
        sloop(node, ivar, source, state, downstream ++ [d], upstream)

      {:add_upstream, u} ->
        sloop(node, ivar, source, state, downstream, upstream ++ [u])

      :dispose ->
        sloop(node, ivar, source, state, downstream, upstream)
        :stop

      {:send, to, payload} ->
        send(to, payload)
        sloop(node, ivar, source, state, downstream, upstream)

      m ->
        IO.puts("Sink did not understand: #{inspect(m)}")
        sloop(node, ivar, source, state, [], [])
    end
  end
end
