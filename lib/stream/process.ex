defmodule Creek.Stream.Process do
  require Logger
  import Creek.{Node, Stream, Wiring}

  @debug false
  @send false
  @meta false
  def debug_in(node, message) do
    if @debug,
      do: IO.puts("#{inspect(self())} - #{inspect(node.name) |> String.pad_trailing(8)}\t <- #{inspect(message)}")
  end

  def debug_out(node, message) do
    if @debug,
      do: IO.puts("#{inspect(self())} - #{inspect(node.name) |> String.pad_trailing(8)}\t -> #{inspect(message)}")
  end

  def debug_stop(node) do
    if @debug,
      do:
        IO.puts(
          IO.ANSI.red() <>
            "#{inspect(self())} - #{inspect(node.name) |> String.pad_trailing(8)}\t stopping" <> IO.ANSI.reset()
        )
  end

  def debug_send(node, message) do
    if @send,
      do: IO.puts("#{inspect(self())} - #{inspect(node.name) |> String.pad_trailing(8)}\t <- #{inspect(message)}")
  end

  def debug_meta_in(node, message) do
    if @meta,
      do:
        IO.puts(
          IO.ANSI.yellow() <>
            "#{inspect(self())} - #{inspect(node.name) |> String.pad_trailing(8)}\t meta-in  #{inspect(message)}" <>
            IO.ANSI.reset()
        )
  end

  def debug_meta_out(node, message) do
    if @meta,
      do:
        IO.puts(
          IO.ANSI.yellow() <>
            "#{inspect(self())} - #{inspect(node.name) |> String.pad_trailing(8)}\t meta-out #{inspect(message)}" <>
            IO.ANSI.reset()
        )
  end

  # -----------------------------------------------------------------------------
  # Source

  def source(node, ds) do
    # Logger.debug("#{inspect(self())} Source running: #{inspect(node)}")
    srloop(node, ds)
  end

  defp srloop(node, ds) do
    # IO.puts """
    # Source: #{inspect self()} : #{inspect :erlang.process_info(self(), :messages)}
    # """
    # Flush out buffer
    receive do
      # Emit sends a message to all the downstreams.
      {:emit_value, value} ->
        for d <- ds do
          send(self(), {:send, d, {:next, self(), value}})
        end

        srloop(node, ds)

      {:emit_complete} ->
        for d <- ds do
          send(self(), {:send, d, {:complete, self()}})
        end

        srloop(node, ds)

      # emit_complete

      {:send, to, payload} ->
        # debug_send(node, {:send, to, payload})

        payload =
          if node.meta do
            debug_meta_in(node, {:out, payload})

            result =
              single({:out, payload})
              ~> node.meta
              |> run(head())
              |> get()

            debug_meta_out(node, result)

            if result != nil do
              result
            else
              payload
            end
          else
            payload
          end

        debug_out(node, payload)
        send(to, payload)

        srloop(node, ds)
    after
      0 ->
        receive do
          {:meta, _from, _payload} ->
            srloop(node, ds)

          {:add_downstream, d} ->
            debug_in(node, {:add_downstream, d})
            debug_in(node, {:add_downstream, d})
            srloop(node, MapSet.put(ds, d))

          {:subscribe, d} ->
            debug_in(node, {:subscribe, d})
            this = %{argument: node.argument}
            node.subscribe.(this)
            srloop(node, ds)

          :dispose ->
            debug_in(node, :dispose)
            send(self(), {:send, self(), :stop})
            srloop(node, ds)

          :stop ->
            debug_stop(node)
            :stop

          m ->
            IO.puts("Source did not understand: #{inspect(m)}")
        end
    end
  end

  # -----------------------------------------------------------------------------
  # Process

  def process(node, ds, us) do
    # Logger.debug("#{inspect(self())} Process running: #{inspect(node)}")
    ploop(node, ds, us)
  end

  defp ploop(node, ds, us) do
    # IO.puts """
    # Operator: #{inspect self()} : #{inspect :erlang.process_info(self(), :messages)}
    # """
    # Flush out buffer
    receive do
      {:emit_value, value} ->
        for d <- ds do
          send(self(), {:send, d, {:next, self(), value}})
        end

        ploop(node, ds, us)

      {:emit_complete} ->
        for d <- ds do
          send(self(), {:send, d, {:complete, self()}})
        end

        ploop(node, ds, us)

      {:emit_dispose_upstream, who} ->
        send(self(), {:send, who, :dispose})
        ploop(node, ds, us)

      {:send, to, payload} ->
        debug_send(node, {:send, to, payload})

        payload =
          if node.meta do
            debug_meta_in(node, {:out, payload})

            result =
              single({:out, payload})
              ~> node.meta
              |> run(head())
              |> get()

            debug_meta_out(node, result)

            if result != nil do
              result
            else
              payload
            end
          else
            payload
          end

        debug_out(node, payload)
        send(to, payload)

        ploop(node, ds, us)
    after
      0 ->
        receive do
          {:meta, _from, _payload} ->
            ploop(node, ds, us)

          {:add_downstream, d} ->
            debug_in(node, {:add_downstream, d})
            ploop(node, MapSet.put(ds, d), us)

          {:add_upstream, u} ->
            debug_in(node, {:add_upstream, u})
            ploop(node, ds, MapSet.put(us, u))

          {:subscribe, who} ->
            debug_in(node, {:subscribe, who})
            for u <- us, do: send(u, {:subscribe, self()})
            ploop(node, ds, us)

          {:next, from, value} ->
            debug_in(node, {:next, from, value})
            this = %{argument: node.argument, downstream: ds |> Enum.to_list()}
            node.next.(this, value)
            ploop(node, ds, us)

          {:complete, upstream} ->
            debug_in(node, {:complete, upstream})
            node.complete.(%{upstream: us}, upstream)
            us = MapSet.delete(us, upstream)
            ploop(node, ds, us)

          :dispose ->
            debug_in(node, :dispose)

            for u <- us do
              send(self(), {:send, u, :dispose})
            end

            send(self(), {:send, self(), :stop})
            ploop(node, ds, us)

          :stop ->
            debug_stop(node)
            :stop

          {:send, to, payload} ->
            debug_in(node, {:send, to, payload})
            send(to, payload)
            ploop(node, ds, us)

          m ->
            IO.puts("Process did not understand: #{inspect(m)}")
            ploop(node, ds, us)
        end
    end
  end

  # -----------------------------------------------------------------------------
  # Sinks

  def sink(node, ivar, source) do
    # Logger.debug("#{inspect(self())} Sink running #{inspect(node)} #{inspect(ivar)} #{inspect(source)}")
    sloop(node, ivar, source, node.state, [], [])
  end

  defp sloop(node, ivar, source, state, downstream, upstream) do
    # IO.puts """
    # Sink: #{inspect self()} : #{inspect :erlang.process_info(self(), :messages)}
    # """
    receive do
      {:yield, value} ->
        Ivar.put(ivar, value)
        debug_out(node, "putting value in ivar: #{inspect(state)}")
        send(self(), {:send, self(), :stop})
        sloop(node, ivar, source, state, downstream, upstream)

      {:emit_value, value} ->
        for d <- downstream do
          send(self(), {:send, d, {:next, self(), value}})
        end

        sloop(node, ivar, source, state, downstream, upstream)

      {:emit_dispose_upstream, who} ->
        send(self(), {:send, who, :dispose})
        sloop(node, ivar, source, state, downstream, upstream)

      {:send, to, payload} ->
        debug_send(node, {:send, to, payload})

        if node.meta do
          result =
            single({:out, payload})
            ~> node.meta
            |> run(head())
            |> get()

          if result != nil do
            {to, payload} = result
            send(to, payload)
            debug_out(node, {to, payload})
          else
            send(to, payload)
            debug_out(node, {to, payload})
          end
        else
          send(to, payload)
          debug_out(node, {to, payload})
        end

        sloop(node, ivar, source, state, downstream, upstream)
    after
      0 ->
        receive do
          {:meta, _from, _payload} ->
            sloop(node, ivar, source, state, downstream, upstream)

          :init ->
            debug_in(node, :init)
            send(self(), {:send, source, {:subscribe, self()}})
            sloop(node, ivar, source, state, downstream, upstream)

          {:subscribe, who} ->
            debug_in(node, {:subscribe, who})
            sloop(node, ivar, source, state, downstream, upstream)

          {:next, from, value} ->
            debug_in(node, {:next, from, value})
            this = %{downstream: downstream, state: state}
            state = node.next.(this, from, value)
            sloop(node, ivar, source, state, downstream, upstream)

          :stop ->
            debug_stop(node)
            :stop

          {:complete, from} ->
            debug_in(node, {:complete, from})
            this = %{downstream: downstream, state: state}
            node.complete.(this, from)

            sloop(node, ivar, source, state, downstream, upstream)

          {:add_downstream, d} ->
            debug_in(node, {:add_downstream, d})
            sloop(node, ivar, source, state, downstream ++ [d], upstream)

          {:add_upstream, u} ->
            debug_in(node, {:add_upstream, u})
            sloop(node, ivar, source, state, downstream, upstream ++ [u])

          :dispose ->
            debug_in(node, :dispose)
            # send(self(), {:send, self(), :stop})
            sloop(node, ivar, source, state, downstream, upstream)

          m ->
            IO.puts("Sink did not understand: #{inspect(m)}")
            sloop(node, ivar, source, state, [], [])
        end
    end
  end
end
