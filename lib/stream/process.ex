defmodule Creek.Stream.Process do
  require Logger
  import Creek.{Wiring, Node, Stream}

  def log(node, message) do
    if false do
      Logger.debug("#{inspect(self())} - #{node.name |> String.pad_trailing(10)}: #{message}")
    end
  end

  def logf(node, message) do
    Logger.debug("#{inspect(self())} - #{node.name |> String.pad_trailing(10)}: #{message}")
  end

  # -----------------------------------------------------------------------------
  # Meta Helpers

  def create_meta_event(event, node, from, state, downstream, upstream, ivar, payload \\ nil) do
    base = %{node: node, ref: self(), state: state}
    %{ivar: ivar, event: event, base: base, from: from, downstream: downstream, upstream: upstream, payload: payload}
  end

  def try_meta(event, node) do
    if node.meta do
      single(event)
      ~> node.meta
      |> run(head())
      |> get()
    else
      :ignore
    end
  end

  ###############################################################################
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
        meta_event = create_meta_event(:add_downstream, node, d, state, ds, MapSet.new(), nil)
        meta_response = try_meta(meta_event, node)

        {state, _us, ds} =
          case meta_response do
            {:ok, {state, us, ds}} ->
              {state, us, ds}

            :ignore ->
              {state, MapSet.new(), MapSet.put(ds, d)}
          end

        srloop(node, state, ds)

      # -------------------------------------------------------------------------
      # Meta only.
      {:meta, {m, payload}, from} ->
        log(node, "meta event from : #{inspect(from)}")
        meta_event = create_meta_event(m, node, from, state, ds, MapSet.new(), payload)
        meta_response = try_meta(meta_event, node)

        {state, _us, ds} =
          case meta_response do
            # Meta-only events must return state.
            {:ok, {state, us, ds}} ->
              {state, us, ds}
          end

        srloop(node, state, ds)

      # -------------------------------------------------------------------------
      # Base protocol.

      {:subscribe, from} ->
        log(node, "subscribe from : #{inspect(from)}")

        meta_event = create_meta_event(:subscribe, node, from, state, ds, MapSet.new(), nil)
        meta_response = try_meta(meta_event, node)

        {state, _us, ds} =
          case meta_response do
            # Default behaviour
            :ignore ->
              this = %{}
              {state, response} = node.subscribe.(this, state, from)

              case response do
                :continue ->
                  send(self(), {:tick, self()})
                  :ok

                _ ->
                  Logger.error("Source callback subscribe/3 produced invalid returnvalue: #{inspect(response)}")
              end

              {state, MapSet.new(), ds}

            # There was a meta-response
            {:ok, {state, us, ds}} ->
              {state, us, ds}
          end

        srloop(node, state, ds)

      {:tick, from} ->
        log(node, "tick")

        meta_event = create_meta_event(:tick, node, from, state, ds, MapSet.new(), nil)
        meta_response = try_meta(meta_event, node)

        {state, _us, ds} =
          case meta_response do
            # Base behaviour in case of no meta.
            :ignore ->
              this = %{}
              {state, response} = node.tick.(this, state)

              case response do
                {:next, value} ->
                  send(self(), {:tick, self()})
                  for d <- ds, do: send(d, {:next, value, self()})

                :complete ->
                  for d <- ds, do: send(d, {:complete, self()})
                  send(self(), {:dispose, self()})

                _ ->
                  Logger.error("Source callback tick/2 produced invalid returnvalue: #{inspect(response)}")
              end

              {state, MapSet.new(), ds}

            # There was a meta-response.
            {:ok, {state, us, ds}} ->
              {state, us, ds}
          end

        srloop(node, state, ds)

      # -------------------------------------------------------------------------
      # Management protocol.

      {:dispose, from} ->
        log(node, "dispose from #{inspect(from)}")
        meta_event = create_meta_event(:dispose, node, from, state, ds, MapSet.new(), nil)
        meta_response = try_meta(meta_event, node)

        {state, _us, ds} =
          case meta_response do
            {:ok, {state, us, ds}} ->
              {state, us, ds}

            :ignore ->
              send(self(), :stop)
              {state, MapSet.new(), ds}
          end

        srloop(node, state, ds)

      :stop ->
        log(node, "stop")
        :stop

      m ->
        IO.puts("#{inspect(self())} Source did not understand: #{inspect(m)}")
    end
  end

  ###############################################################################
  ###############################################################################
  ###############################################################################
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
        meta_event = create_meta_event(:add_downstream, node, d, state, ds, us, nil)
        meta_response = try_meta(meta_event, node)

        {state, us, ds} =
          case meta_response do
            {:ok, {state, us, ds}} ->
              {state, us, ds}

            :ignore ->
              {state, us, MapSet.put(ds, d)}
          end

        ploop(node, state, ds, us)

      {:add_upstream, u} ->
        log(node, "add upstream #{inspect(u)}")
        meta_event = create_meta_event(:add_upstream, node, u, state, ds, us, nil)
        meta_response = try_meta(meta_event, node)

        {state, us, ds} =
          case meta_response do
            {:ok, {state, us, ds}} ->
              {state, us, ds}

            :ignore ->
              {state, MapSet.put(us, u), ds}
          end

        ploop(node, state, ds, us)

      # -------------------------------------------------------------------------
      # Meta only.
      {:meta, {m, payload}, from} ->
        log(node, "meta event from : #{inspect(from)}")
        meta_event = create_meta_event(m, node, from, state, ds, us, payload)
        meta_response = try_meta(meta_event, node)

        {state, us, ds} =
          case meta_response do
            # Meta-only events must return state.
            {:ok, {state, us, ds}} ->
              {state, us, ds}
          end

        ploop(node, state, ds, us)

      # -------------------------------------------------------------------------
      # Base protocol.

      # Operators just send the subscribe upstream.
      {:subscribe, from} ->
        meta_event = create_meta_event(:subscribe, node, from, state, ds, us, nil)
        meta_response = try_meta(meta_event, node)

        {state, us, ds} =
          case meta_response do
            # Default behaviour
            :ignore ->
              log(node, "subscribe from : #{inspect(from)}")
              for u <- us, do: send(u, {:subscribe, self()})
              # ploop(node, state, ds, us)
              {state, us, ds}

            {:ok, {state, us, ds}} ->
              {state, us, ds}
          end

        ploop(node, state, ds, us)

      {:next, value, from} ->
        log(node, "next #{inspect(value)} from #{inspect(from)}")

        meta_event = create_meta_event(:next, node, from, state, ds, us, nil, value)
        meta_response = try_meta(meta_event, node)

        {state, us, ds} =
          case meta_response do
            :ignore ->
              this = %{arg: node.argument, downstream: Enum.to_list(ds)}
              {state, response} = node.next.(this, state, from, value)

              case response do
                {:next, value} ->
                  for d <- ds, do: send(d, {:next, value, self()})

                :skip ->
                  :ok

                _ ->
                  Logger.error("#{inspect(self())} Operator callback subscribe/3 produced invalid returnvalue: #{inspect(response)}")
              end

              {state, us, ds}

            # There was a meta-level response.
            {:ok, {state, us, ds}} ->
              {state, us, ds}
          end

        ploop(node, state, ds, us)

      {:complete, from} ->
        log(node, "complete from #{inspect(from)} (#{Enum.count(us)} upstreams)")
        meta_event = create_meta_event(:complete, node, from, state, ds, us, nil)
        meta_response = try_meta(meta_event, node)

        {state, us, ds} =
          case meta_response do
            :ignore ->
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
                {state, us, ds}
                # ploop(node, state, ds, us)
              else
                send(from, {:dispose, self()})
                us = MapSet.delete(us, from)
                {state, us, ds}
                # ploop(node, state, ds, us)
              end

            {:ok, {state, us, ds}} ->
              {state, us, ds}
          end

        ploop(node, state, ds, us)

      # -------------------------------------------------------------------------
      # Management protocol.

      {:dispose, from} ->
        log(node, "dispose from #{inspect(from)}")
        meta_event = create_meta_event(:dispose, node, from, state, ds, MapSet.new(), nil)
        meta_response = try_meta(meta_event, node)

        {state, us, ds} =
          case meta_response do
            {:ok, {state, us, ds}} ->
              {state, us, ds}

            :ignore ->
              # If we dispose ourselves we must do so.
              # If the dispose is from downstream we ignore it if we have other downstreams.
              if from == self() or Enum.count(ds) == 1 do
                # Let our upstream know to dispose.
                for u <- us, do: send(u, {:dispose, self()})

                send(self(), :stop)
              end

              {state, us, ds}
          end

        ploop(node, state, ds, us)

      :stop ->
        log(node, "stop")
        :stop

      m ->
        IO.puts("#{inspect(self())} Process did not understand: #{inspect(m)}")
        ploop(node, state, ds, us)
    end
  end

  ###############################################################################
  ###############################################################################
  ###############################################################################
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
      # Meta only.
      {:meta, {m, payload}, from} ->
        log(node, "meta event from : #{inspect(from)}")
        meta_event = create_meta_event(m, node, from, state, ds, us, payload)
        meta_response = try_meta(meta_event, node)

        {state, us, ds} =
          case meta_response do
            # Meta-only events must return state.
            {:ok, {state, us, ds}} ->
              {state, us, ds}
          end

        sloop(node, ivar, source, state, ds, us)

      # -------------------------------------------------------------------------
      # Base protocol.
      {:subscribe, from} ->
        log(node, "subscribe from : #{inspect(from)}")
        meta_event = create_meta_event(:subscribe, node, from, state, ds, us, nil)
        meta_response = try_meta(meta_event, node)

        {state, us, ds} =
          case meta_response do
            # Default behaviour
            :ignore ->
              for u <- us, do: send(u, {:subscribe, self()})
              {state, us, ds}

            # Meta handled the call.
            {:ok, {state, us, ds}} ->
              {state, us, ds}
          end

        sloop(node, ivar, source, state, ds, us)

      {:next, value, from} ->
        log(node, "next #{inspect(value)} from #{inspect(from)}")
        meta_event = create_meta_event(:next, node, from, state, ds, us, ivar, value)
        meta_response = try_meta(meta_event, node)

        {state, us, ds} =
          case meta_response do
            # Default behaviour
            :ignore ->
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

              {state, us, ds}

            # Meta handled the call.
            {:ok, {state, us, ds}} ->
              {state, us, ds}
          end

        sloop(node, ivar, source, state, ds, us)

      {:complete, from} ->
        log(node, "complete from #{inspect(from)}")
        meta_event = create_meta_event(:complete, node, from, state, ds, us, ivar)
        meta_response = try_meta(meta_event, node)

        {state, us, ds} =
          case meta_response do
            :ignore ->
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

              {state, us, ds}

            {:ok, {state, us, ds}} ->
              {state, us, ds}
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
        IO.puts("#{inspect(self())} Sink did not understand: #{inspect(m)}")
        sloop(node, ivar, source, state, MapSet.new(), MapSet.new())
    end
  end
end
