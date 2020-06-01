defmodule Creek.Meta.PullSlow do
  require Logger
  import Creek.{Node}

  def source() do
    map(fn %{event: event, base: base, from: from, downstream: downstream, upstream: upstream, payload: _payload} ->
      case event do
        # -----------------------------------------------------------------------
        :subscribe ->
          this = %{}
          # Call the base-level subscribe method.
          {state, response} = base.node.subscribe.(this, base.state, from)

          # The base must always reply with a :continue.
          # The base must stop or continue in the tick callback.
          case response do
            :continue ->
              :ok

            _ ->
              Logger.error("Source callback subscribe/3 produced invalid returnvalue: #{inspect(response)}")
          end

          {:ok, {state, upstream, downstream}}

        # -------------------------------\stx----------------------------------------
        :tick ->
          this = %{}
          IO.puts("Source Ticking")
          # Call the base-level tick method.
          {state, response} = base.node.tick.(this, base.state)

          case response do
            {:next, value} ->
              # send(base.ref, {:tick, base.ref})
              for d <- downstream, do: send(d, {:next, value, base.ref})

            :complete ->
              for d <- downstream, do: send(d, {:complete, base.ref})
              send(base.ref, {:dispose, base.ref})

            _ ->
              Logger.error("Source callback tick/2 produced invalid returnvalue: #{inspect(response)}")
          end

          {:ok, {state, upstream, downstream}}

        # -----------------------------------------------------------------------
        :demand ->
          send(base.ref, {:tick, base.ref})
          {:ok, {base.state, upstream, downstream}}

        # -----------------------------------------------------------------------
        # If the meta-layer doesn't want to handle a type of event it just ignores it
        # and the interpreter will handle it with the default behaviour.
        _ ->
          IO.puts("Unhandled meta-event in source: `#{inspect(event)}`")
          :ignore
      end
    end)
  end

  def operator() do
    map(fn %{event: event, base: base, from: from, downstream: downstream, upstream: upstream, payload: payload} ->
      case event do
        # -----------------------------------------------------------------------
        :next ->
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
        :demand ->
          for u <- upstream, do: send(u, {:meta, {:demand, payload}, base.ref})
          {:ok, {base.state, upstream, downstream}}

        # -----------------------------------------------------------------------

        _ ->
          IO.puts("Unhandled meta event in operator: `#{inspect(event)}`")
          :ignore
      end
    end)
  end

  def sink() do
    map(fn %{ivar: ivar, event: event, base: base, from: from, downstream: downstream, upstream: upstream, payload: payload} ->
      case event do
        :subscribe ->
          for u <- upstream, do: send(u, {:subscribe, base.ref})
          for u <- upstream, do: send(u, {:meta, {:demand, 1}, self()})
          {:ok, {base.state, upstream, downstream}}

        :next ->
          IO.puts("Sink got value!")
          Process.sleep(5000)
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

          # Send demand.
          for u <- upstream, do: send(u, {:meta, {:demand, 1}, base.ref})
          {:ok, {state, upstream, downstream}}

        # -----------------------------------------------------------------------
        :demand ->
          for u <- upstream, do: send(u, {:meta, {:demand, payload}, base.ref})
          {:ok, {base.state, upstream, downstream}}

        # -----------------------------------------------------------------------

        _ ->
          IO.puts("Unhandled meta-event in sink: `#{inspect(event)}`")
          :ignore
      end
    end)
  end
end
