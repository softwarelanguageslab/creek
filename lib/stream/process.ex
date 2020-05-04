defmodule Creek.Stream.Process do
  require Logger

  def log(node, message) do
    Logger.debug("#{inspect(self())} - #{node.name |> String.pad_trailing(10)}: #{message}")
  end

  # -----------------------------------------------------------------------------
  # Source

  def source(node, state, ds) do
    srloop(node, state, ds)
  end

  defp srloop(node, state, ds) do
    receive do
      # -------------------------------------------------------------------------
      # Bookkeeping for stream topology.

      {:add_downstream, d} ->
        log(node, "add downstream: #{inspect(d)}")
        srloop(node, state, MapSet.put(ds, d))

      # -------------------------------------------------------------------------
      # Base protocol.

      {:subscribe, from} ->
        log(node, "subscribe from : #{inspect(from)}")
        # Unused in the streams for now.
        this = %{}
        {state, response} = node.subscribe.(this, state, from)

        case response do
          :continue ->
            send(self(), :tick)
            :ok

          _ ->
            Logger.error("Source callback subscribe/3 produced invalid returnvalue: #{inspect(response)}")
        end

        srloop(node, state, ds)

      # -------------------------------------------------------------------------
      # Management protocol.

      :tick ->
        log(node, "tick")
        # Unused in the streams for now.
        this = %{}
        {state, response} = node.tick.(this, state)

        case response do
          {:next, value} ->
            send(self(), :tick)
            for d <- ds, do: send(d, {:next, value, self()})

          :complete ->
            for d <- ds, do: send(d, {:complete, self()})
            send(self(), {:dispose, self()})

          _ ->
            Logger.error("Source callback tick/2 produced invalid returnvalue: #{inspect(response)}")
        end

        srloop(node, state, ds)

      {:dispose, from} ->
        log(node, "dispose from #{inspect(from)}")
        send(self(), :stop)
        srloop(node, state, ds)

      :stop ->
        log(node, "stop")
        :stop

      m ->
        IO.puts("Source did not understand: #{inspect(m)}")
    end
  end

  # -----------------------------------------------------------------------------
  # Process

  def process(node, state, ds, us) do
    ploop(node, state, ds, us)
  end

  defp ploop(node, state, ds, us) do
    receive do
      # -------------------------------------------------------------------------
      # Bookkeeping for stream topology.

      {:add_downstream, d} ->
        log(node, "add downstream: #{inspect(d)}")
        ploop(node, state, MapSet.put(ds, d), us)

      {:add_upstream, u} ->
        log(node, "add upstream #{inspect(u)}")
        ploop(node, state, ds, MapSet.put(us, u))

      # -------------------------------------------------------------------------
      # Base protocol.

      # Operators just send the subscribe upstream.
      {:subscribe, from} ->
        log(node, "subscribe from : #{inspect(from)}")
        for u <- us, do: send(u, {:subscribe, self()})
        ploop(node, state, ds, us)

      {:next, value, from} ->
        log(node, "next #{inspect(value)} from #{inspect(from)}")
        this = %{arg: node.argument, downstream: Enum.to_list(ds)}
        {state, response} = node.next.(this, state, from, value)

        case response do
          {:next, value} ->
            for d <- ds, do: send(d, {:next, value, self()})

          :skip ->
            :ok

          _ ->
            Logger.error(
              "#{inspect(self())} Operator callback subscribe/3 produced invalid returnvalue: #{inspect(response)}"
            )
        end

        ploop(node, state, ds, us)

      {:complete, from} ->
        log(node, "complete from #{inspect(from)} (#{Enum.count(us)} upstreams)")

        # We only call the complete callback when all upstreams completed.
        if Enum.count(us) == 1 do
          this = %{}
          {state, response} = node.complete.(this, state)

          case response do
            :complete ->
              for d <- ds, do: send(d, {:complete, self()})
              :ok

            _ ->
              Logger.error("Operator callback complete/3 produced invalid returnvalue: #{inspect(response)}")
          end

          # Remove the stream from our upstream and send it the dispose signal.
          send(from, {:dispose, self()})
          us = MapSet.delete(us, from)
          ploop(node, state, ds, us)
        else
          send(from, {:dispose, self()})
          us = MapSet.delete(us, from)
          ploop(node, state, ds, us)
        end

      # -------------------------------------------------------------------------
      # Management protocol.

      {:dispose, from} ->
        log(node, "dispose from #{inspect(from)}")
        # If we dispose ourselves we must do so.
        # If the dispose is from downstream we ignore it if we have other downstreams.
        if from == self() or Enum.count(ds) == 1 do
          # Let our upstream know to dispose.
          for u <- us, do: send(u, {:dispose, self()})

          send(self(), :stop)
        end

        ploop(node, state, ds, us)

      :stop ->
        log(node, "stop")
        :stop

      m ->
        IO.puts("Process did not understand: #{inspect(m)}")
        ploop(node, state, ds, us)
    end
  end

  # -----------------------------------------------------------------------------
  # Sinks

  def sink(node, ivar, source) do
    sloop(node, ivar, source, node.state, MapSet.new(), MapSet.new())
  end

  defp sloop(node, ivar, source, state, ds, us) do
    receive do
      # -------------------------------------------------------------------------
      # Bookkeeping for stream topology.
      {:add_downstream, d} ->
        log(node, "add downstream: #{inspect(d)}")
        sloop(node, ivar, source, state, MapSet.put(ds, d), us)

      {:add_upstream, u} ->
        log(node, "add upstream #{inspect(u)}")
        sloop(node, ivar, source, state, ds, MapSet.put(us, u))

      # -------------------------------------------------------------------------
      # Base protocol.

      {:subscribe, from} ->
        log(node, "subscribe from : #{inspect(from)}")
        for u <- us, do: send(u, {:subscribe, self()})
        sloop(node, ivar, source, state, ds, us)

      {:next, value, from} ->
        log(node, "next #{inspect(value)} from #{inspect(from)}")
        this = %{}

        {state, response} = node.next.(this, state, from, value)

        case response do
          {:next, value} ->
            for d <- ds, do: send(d, {:next, value, self()})

          :skip ->
            :ok

          {:yield, value} ->
            Ivar.put(ivar, value)
            send(self(), {:dispose, self()})
            for d <- ds, do: send(d, {:complete, self()})
        end

        sloop(node, ivar, source, state, ds, us)

      {:complete, from} ->
        log(node, "complete from #{inspect(from)}")
        this = %{}
        {state, response} = node.complete.(this, state)

        case response do
          {:complete, _state} ->
            send(self(), {:dispose, self()})
            for d <- ds, do: send(d, {:complete, self()})

          {:yield, value} ->
            log(node, "Putting value #{inspect(value)} in ivar")
            Ivar.put(ivar, value)
            send(self(), {:dispose, self()})
            for d <- ds, do: send(d, {:complete, self()})
        end

        sloop(node, ivar, source, state, ds, us)

      # -------------------------------------------------------------------------
      # Management protocol.

      {:dispose, from} ->
        log(node, "dispose from #{inspect(from)}")
        # Let our upstream know to dispose.
        for u <- us, do: send(u, {:dispose, self()})

        send(self(), :stop)
        sloop(node, ivar, source, state, ds, us)

      :stop ->
        log(node, "stop")
        :stop

      m ->
        IO.puts("Sink did not understand: #{inspect(m)}")
        sloop(node, ivar, source, state, [], [])
    end
  end
end
