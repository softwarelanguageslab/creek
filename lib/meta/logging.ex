defmodule Creek.Meta.Logging do
  require Logger
  import Creek.{Node}

  def source() do
    map(fn %{event: event, base: base, from: from, downstream: downstream, upstream: upstream, payload: _payload} ->
      case event do
        # -----------------------------------------------------------------------
        :dispose ->
          IO.puts("Meta: Source received dispose event")
          send(base.ref, :stop)
          {:ok, {base.state, upstream, downstream}}

        # -----------------------------------------------------------------------
        :subscribe ->
          IO.puts("Meta: Source received subscribe event")
          this = %{}
          # Call the base-level subscribe method.
          {state, response} = base.node.subscribe.(this, base.state, from)

          # The base must always reply with a :continue.
          # The base must stop or continue in the tick callback.
          case response do
            :continue ->
              send(base.ref, {:tick, base.ref})
              :ok

            _ ->
              Logger.error("Source callback subscribe/3 produced invalid returnvalue: #{inspect(response)}")
          end

          # The return value from the meta-layer is the state.
          {:ok, {state, upstream, downstream}}

        # -----------------------------------------------------------------------
        :tick ->
          IO.puts("Meta: Source received tick event")
          this = %{}
          # Call the base-level tick method.
          {state, response} = base.node.tick.(this, base.state)

          case response do
            {:next, value} ->
              send(base.ref, {:tick, base.ref})
              for d <- downstream, do: send(d, {:next, value, base.ref})

            :complete ->
              for d <- downstream, do: send(d, {:complete, base.ref})
              send(base.ref, {:dispose, base.ref})

            _ ->
              Logger.error("Source callback tick/2 produced invalid returnvalue: #{inspect(response)}")
          end

          {:ok, {state, upstream, downstream}}

        # -----------------------------------------------------------------------
        # If the meta-layer doesn't want to handle a type of event it just ignores it
        # and the interpreter will handle it with the default behaviour.
        _ ->
          :ignore
      end
    end)
  end

  def operator() do
    map(fn %{event: event, base: base, from: from, downstream: downstream, upstream: upstream, payload: payload} ->
      case event do
        # -----------------------------------------------------------------------
        :dispose ->
          IO.puts("Operator got dispose event.")
          send(base.ref, :stop)
          {:ok, {base.state, upstream, downstream}}

        # -----------------------------------------------------------------------
        :subscribe ->
          IO.puts("Operator got susbcribe event.")
          for u <- upstream, do: send(u, {:subscribe, base.ref})
          # ploop(node, state, ds, us)
          {:ok, {base.state, upstream, downstream}}

        # -----------------------------------------------------------------------
        :next ->
          IO.puts("Operator got value: #{payload}")
          this = %{arg: base.node.argument, downstream: Enum.to_list(downstream)}
          {state, response} = base.node.next.(this, base.state, from, payload)

          case response do
            {:next, value} ->
              for d <- downstream, do: send(d, {:next, value, base.ref})

            :skip ->
              :ok

            _ ->
              Logger.error("#{inspect(base.ref)} Operator callback subscribe/3 produced invalid returnvalue: #{inspect(response)}")
          end

          {:ok, {state, upstream, downstream}}

        # -----------------------------------------------------------------------
        :complete ->
          IO.puts("Operator got complete")
          # We only call the complete callback when all upstreams completed.
          if Enum.count(upstream) == 1 do
            this = %{}
            {state, response} = base.node.complete.(this, base.state)

            case response do
              :complete ->
                for d <- downstream, do: send(d, {:complete, base.ref})
                :ok

              _ ->
                Logger.error("Operator callback complete/3 produced invalid returnvalue: #{inspect(response)}")
            end

            # Remove the stream from our upstream and send it the dispose signal.
            send(from, {:dispose, base.ref})
            upstream = MapSet.delete(upstream, from)
            {:ok, {state, upstream, downstream}}
            # ploop(node, state, ds, us)
          else
            send(from, {:dispose, base.ref})
            upstream = MapSet.delete(upstream, from)
            {:ok, {base.state, upstream, downstream}}
            # ploop(node, state, ds, us)
          end

        _ ->
          :ignore
      end
    end)
  end

  def sink() do
    map(fn %{ivar: ivar, event: event, base: base, from: from, downstream: downstream, upstream: upstream, payload: payload} ->
      case event do
        :subscribe ->
          for u <- upstream, do: send(u, {:subscribe, base.ref})
          {:ok, {base.state, upstream, downstream}}

        :next ->
          this = %{arg: base.node.argument, downstream: Enum.to_list(downstream)}
          {state, response} = base.node.next.(this, base.state, from, payload)

          case response do
            {:next, value} ->
              for d <- downstream, do: send(d, {:next, value, base.ref})

            :skip ->
              :ok

            {:yield, value} ->
              Ivar.put(ivar, value)
              send(base.ref, {:dispose, base.ref})
              for d <- downstream, do: send(d, {:complete, base.ref})
          end

          {:ok, {state, upstream, downstream}}

        :complete ->
          this = %{}
          {state, response} = base.node.complete.(this, base.state)

          case response do
            {:complete, _state} ->
              send(base.ref, {:dispose, base.ref})
              for d <- downstream, do: send(d, {:complete, base.ref})

            {:yield, value} ->
              Ivar.put(ivar, value)
              send(base.ref, {:dispose, base.ref})
              for d <- downstream, do: send(d, {:complete, base.ref})
          end

          {:ok, {state, upstream, downstream}}

        _ ->
          :ignore
      end
    end)
  end
end
