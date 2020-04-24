defmodule Creek.Stream.Process do
  require Logger
  import Creek.{Node, Stream, Wiring}

  @debug true
  @send true
  @meta true
  def debug_in(node, message) do
    if @debug, do: IO.puts("#{inspect(self())} - #{inspect(node.name) |> String.pad_trailing(8)}\t <- #{inspect(message)}")
  end

  def debug_out(node, message) do
    if @debug, do: IO.puts("#{inspect(self())} - #{inspect(node.name) |> String.pad_trailing(8)}\t -> #{inspect(message)}")
  end

  def debug_stop(node) do
    if @debug, do: IO.puts(IO.ANSI.red() <> "#{inspect(self())} - #{inspect(node.name) |> String.pad_trailing(8)}\t stopping" <> IO.ANSI.reset())
  end

  def debug_send(node, message) do
    if @send, do: IO.puts("#{inspect(self())} - #{inspect(node.name) |> String.pad_trailing(8)}\t <- #{inspect(message)}")
  end

  def debug_meta_in(node, message) do
    if @meta,
      do:
        IO.puts(
          IO.ANSI.yellow() <>
            "#{inspect(self())} - #{inspect(node.name) |> String.pad_trailing(8)}\t meta-in  #{inspect(message)}" <> IO.ANSI.reset()
        )
  end

  def debug_meta_out(node, message) do
    if @meta,
      do:
        IO.puts(
          IO.ANSI.yellow() <>
            "#{inspect(self())} - #{inspect(node.name) |> String.pad_trailing(8)}\t meta-out #{inspect(message)}" <> IO.ANSI.reset()
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

        srloop(node, ds)
    after
      0 ->
        receive do
          {:add_downstream, d} ->
            debug_in(node, {:add_downstream, d})
            debug_in(node, {:add_downstream, d})
            srloop(node, MapSet.put(ds, d))

          {:subscribe, d} ->
            debug_in(node, {:subscribe, d})
            node.subscribe.(node.argument, ds)
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

          {:next, value} ->
            debug_in(node, {:next, value})
            # Check to see if there is a meta level.
            {:next, value} =
              if node.meta do
                debug_meta_in(node, {:in, {:next, value}})

                result =
                  single({:in, {:next, value}})
                  ~> node.meta
                  |> run(head())
                  |> get()

                debug_meta_out(node, result)

                if result != nil do
                  result
                else
                  {:next, value}
                end
              else
                {:next, value}
              end

            node.next.(node.argument, value, ds)
            ploop(node, ds, us)

          {:complete, upstream} ->
            debug_in(node, {:complete, upstream})
            node.complete.(upstream, us, ds)
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
          :init ->
            debug_in(node, :init)
            send(self(), {:send, source, {:subscribe, self()}})
            sloop(node, ivar, source, state, downstream, upstream)

          {:subscribe, who} ->
            debug_in(node, {:subscribe, who})
            sloop(node, ivar, source, state, downstream, upstream)

          {:next, value} ->
            debug_in(node, {:next, value})

            {:next, value} =
              if node.meta do
                debug_meta_in(node, {:in, {:next, value}})

                result =
                  single({:in, {:next, value}})
                  ~> node.meta
                  |> run(head())
                  |> get()

                debug_meta_out(node, result)

                if result != nil do
                  result
                else
                  {:next, value}
                end
              else
                {:next, value}
              end

            state = node.next.(node, value, state, downstream)

            case state do
              {:continue, state} ->
                sloop(node, ivar, source, state, downstream, upstream)

              {:done, state} ->
                Ivar.put(ivar, state)
                send(self(), {:send, source, :dispose})
                send(self(), {:send, self(), :stop})
                sloop(node, ivar, source, state, downstream, upstream)
            end

          :stop ->
            debug_stop(node)
            :stop

          {:complete, from} ->
            debug_in(node, {:complete, from})
            result = node.complete.(state, downstream)

            case result do
              {:done, state} ->
                Ivar.put(ivar, state)
                debug_out(node, "putting value in ivar: #{inspect(state)}")
                send(self(), {:send, source, :dispose})
                send(self(), {:send, self(), :stop})
                sloop(node, ivar, source, state, downstream, upstream)

              {:continue, state} ->
                for d <- downstream do
                  send(self(), {:send, d, {:complete, self()}})
                end

                sloop(node, ivar, source, state, downstream, upstream)
            end

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
