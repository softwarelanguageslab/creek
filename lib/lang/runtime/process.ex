defmodule Creek.Runtime.Process do
  require Logger

  @warn true
  defstruct pid: nil, ref: nil

  def new(pid, ref) do
    %Creek.Runtime.Process{pid: pid, ref: ref}
  end

  ##############################################################################
  # Logging

  @log false
  @meta false
  def log(message) do
    if @log do
      IO.puts("#{inspect(self())}: #{message}")
    end
  end

  def warn(message) do
    if @warn do
      IO.puts(IO.ANSI.yellow() <> "WARN #{inspect(self())}: #{message}" <> IO.ANSI.reset())
    end
  end

  def err(message) do
    if @warn do
      IO.puts(IO.ANSI.red() <> "ERR  #{inspect(self())}: #{message}" <> IO.ANSI.reset())
    end
  end

  def log_meta(message) do
    if @meta do
      IO.puts(IO.ANSI.yellow_background() <> IO.ANSI.green() <> "#{inspect(self())}: #{message}" <> IO.ANSI.reset())
    end
  end

  def warn_meta(message) do
    if @meta do
      IO.puts(IO.ANSI.black_background() <> IO.ANSI.yellow() <> IO.ANSI.yellow() <> "WARN #{inspect(self())}: #{message}" <> IO.ANSI.reset())
    end
  end

  def err_meta(message) do
    if @meta do
      IO.puts(IO.ANSI.yellow_background() <> IO.ANSI.red() <> "ERR  #{inspect(self())}: #{message}" <> IO.ANSI.reset())
    end
  end

  def debug_meta(message) do
    if @meta do
      IO.puts(IO.ANSI.yellow_background() <> IO.ANSI.black() <> "DBG  #{inspect(self())}: #{message}" <> IO.ANSI.reset())
    end
  end

  ##############################################################################
  # Source #####################################################################
  ##############################################################################

  def source(node, downstreams) do
    Process.flag :trap_exit, true
    source_loop(node, downstreams, node.arg, nil)
  end

  def source_loop(node, downstreams, state, meta_state) do
    receive do
      ###############
      # Bookkeeping #
      ###############
      {:offer_meta, meta_dag, args} ->
        warn("SRC: Deploying meta DAG")
        if meta_dag != nil do
          source = Creek.Source.subject(description: "meta subject")
          sink = Creek.Sink.tap(self())
          Creek.Runtime.run(meta_dag, [src: source, snk: sink] ++ args, meta: true)
          node = %{node | meta: source}
          source_loop(node, downstreams, state, meta_state)
        else
          source_loop(node, downstreams, state, meta_state)
        end

      {:add_downstream, downstream} ->
        # warn("SRC: Adding downstream #{inspect(downstream)} (current: #{inspect(downstreams)}")
        {pid, _from_gate, _} = downstream
        Process.monitor(pid)
        source_loop(node, [downstream | downstreams], state, meta_state)

      {:delete_downstream, downstream} ->
        # warn("SRC: Removing downstream #{inspect(downstream)} (current: #{inspect(downstreams)}")
        new_downstreams = Enum.filter(downstreams, &(downstream != &1))

        if new_downstreams == [] do
          send_self({:finish})
          warn("SRC: No downstreams left anymore.")
        else
          warn("SRC: Other downstreams left.")
        end

        source_loop(node, new_downstreams, state, meta_state)

      {:finish} ->
        warn("SRC: Finished")
        # If a source receives a finish it simply finishes.
        # The finish message *always* comes from the process itself.
        # Itonly has one downstream and that received the complete message.
        :finished

      {:DOWN, _ref, _, down_pid, _} ->
        warn("SRC: Node down")
        for down_ds <-  Enum.filter(downstreams, fn {pid, _, _} -> down_pid == pid end) do
          send(self(), {:delete_downstream, down_ds})
        end

        source_loop(node, downstreams, state, meta_state)

      #################
      # Base Protocol #
      #################
      {:meta_message, m, from} ->
        # debug_meta(("SRC: Direct Meta Message :: #{inspect(m)}")

        if node.meta != nil do
          source = node.meta
          # ref = make_ref()()
          meta_event = {%{meta_state: meta_state, pid: self(), state: state, gate: nil, node: node, us: [], ds: downstreams}, :meta, m, from}
          # debug_meta(("SRC :: METAM :: Meta In  ::#{inspect(ref)} -> #{inspect(source)}")
          Creek.Source.Subject.next(source, meta_event)

          receive do
            {p = %{}, :ok} ->
              # debug_meta(("SRC :: METAM :: Meta Out ::#{inspect(ref)}")
              source_loop(node, p.ds, p.state, p.meta_state)
          after
            1000 ->
              raise "SRC:: Timeout waiting for meta-level response to meta message #{inspect(m)}."
          end
        else
          source_loop(node, downstreams, state, meta_state)
        end

      {:initialize} ->
        # warn("SRC: Initializing")
        # Initial state.

        if node.meta != nil do
          source = node.meta
          # ref = make_ref()()
          meta_event = {%{meta_state: meta_state, pid: self(), state: state, gate: nil, node: node, us: [], ds: downstreams}, :init_src}
          # log_meta("SRC :: INIT :: Meta In  ::#{inspect(ref)} -> #{inspect(source)}")
          Creek.Source.Subject.next(source, meta_event)

          receive do
            {p = %{}, :ok} ->
              # log_meta("SRC :: INIT :: Meta Out ::#{inspect(ref)}")
              source_loop(node, p.ds, p.state, p.meta_state)
          after
            1000 ->
              raise "SRC:: Timeout waiting for meta-level response to initialize."
          end
        else
          state = node.arg
          response = node.impl.initialize(node, state)

          case response do
            {state, :initialized} ->
              effects_initialize_source(self())
              source_loop(node, downstreams, state, meta_state)

              _ ->
              warn("SRC: initialize invalid return value!")
          end
        end

      {:tick} ->
        if node.meta != nil do
          source = node.meta
          # ref = make_ref()()
          meta_event = {%{meta_state: meta_state, pid: self(), state: state, gate: nil, node: node, us: [], ds: downstreams}, :tick}
          # log_meta("SRC :: INIT :: Meta In  ::#{inspect(ref)} -> #{inspect(source)}")
          Creek.Source.Subject.next(source, meta_event)

          receive do
            {p = %{}, :ok} ->
              # log_meta("SRC :: INIT :: Meta Out ::#{inspect(ref)}")
              source_loop(node, p.ds, p.state, p.meta_state)
          after
            50000 ->
              raise "SRC:: Timeout waiting for meta-level response to tick."
          end
        else
          response = node.impl.tick(node, state)

          case response do
            {state, :tick, value} ->
              # log("SRC: Emitting #{inspect(value)}")
              effects_tick_value(self(), value, downstreams)
              source_loop(node, downstreams, state, meta_state)

            {state, :complete} ->
              warn("SRC: Completed")
              propagate_downstream({:complete}, downstreams, self())
              send_self({:finish})
              source_loop(node, downstreams, state, meta_state)

            _ ->
              nil
              warn("SRC: tick invalid return value!")
          end
        end

      m ->
        nil
        warn("SRC: Message not understood: #{inspect(m)}")
    end
  end

  ##############################################################################
  # Operator ###################################################################
  ##############################################################################

  def process(node, upstreams, downstreams) do
    Process.flag :trap_exit, true

    # warn("OPR: Starting @ #{inspect(self())}")

    if node.meta != nil do
      # log_meta("Starting operator with meta-runtime #{inspect(self())}")
      # We spawn the META graph of this process.
      source = Creek.Source.subject(description: "meta subject")
      sink = Creek.Sink.tap(self())
      inject_tap = Creek.Sink.tap(self())
      Creek.Runtime.run(node.meta, [src: source, snk: sink] ++ node.meta_sink, meta: true)

      if node.meta_in != [] do
        Creek.Runtime.run(Proxy.proxy(), [src: node.meta_in] ++ [snk: inject_tap], meta: true)
      end

      process_loop(%{node | meta: source}, upstreams, downstreams, node.arg, nil)
    else
      # log_meta("Starting operator without meta-runtime")
      process_loop(node, upstreams, downstreams, node.arg, nil)
    end
  end

  def process_loop(node, upstreams, downstreams, state, meta_state) do
    receive do
      ###############
      # Bookkeeping #
      ###############
      {:add_downstream, downstream} ->
        {pid, from_gate, _} = downstream
        Process.monitor(pid)
        # warn("OPR: Adding downstream #{inspect(downstream)} (current: #{inspect(downstreams)}")
        process_loop(node, upstreams, [downstream | downstreams], state, meta_state)

      {:delete_downstream, downstream} ->
        # warn("OPR: Removing downstream #{inspect(downstream)} (current: #{inspect(downstreams)}")
        new_downstreams = Enum.filter(downstreams, &(downstream != &1))

        if new_downstreams == [] do
          warn("OPR: No downstreams left anymore.")
          send_self({:finish})
          propagate_upstream({:delete_downstream}, upstreams, self())
        else
          warn("OPR: Still downstreams left: #{inspect(new_downstreams)}")
        end

        process_loop(node, upstreams, new_downstreams, state, meta_state)

      {:add_upstream, upstream} ->
        {pid, _, to_gate} = upstream
        Process.monitor(pid)
        # warn("OPR: Adding upstream #{inspect(upstream)} (current: #{inspect(upstreams)}")
        process_loop(node, [upstream | upstreams], downstreams, state, meta_state)

      {:finish} ->
        warn("OPR: Finished (#{inspect(self())})")
        :finished

      {:DOWN, _ref, _, down_pid, _} ->
        warn("OPR: Node down: #{inspect down_pid}")

        for down_ds <-  Enum.filter(downstreams, fn {pid, _, _} -> down_pid == pid end) do
          # IO.puts "Sending delete_downstream to #{inspect down_ds}"
          send(self(), {:delete_downstream, down_ds})
        end

        for down_us <- Enum.filter(upstreams, fn {pid, _, _} -> down_pid == pid end) do
          # IO.puts "Sending complete to #{inspect down_us}"
          send(self(), {:complete, down_us})
        end

        process_loop(node, upstreams, downstreams, state, meta_state)

      #################
      # Base Protocol #
      #################
      {:meta_message, m, from} ->
        # debug_meta(("OPR: (#{node.name}) Direct Meta Message :: #{inspect(m)}")
        if node.meta != nil do
          source = node.meta
          # ref = make_ref()()
          meta_event = {%{meta_state: meta_state, pid: self(), state: state, gate: nil, node: node, us: upstreams, ds: downstreams}, :meta, m, from}
          # debug_meta(("OPR :: METAM :: Meta In  ::#{inspect(ref)} -> #{inspect(source)}")
          Creek.Source.Subject.next(source, meta_event)

          receive do
            {p = %{}, :ok} ->
              # debug_meta(("OPR :: METAM :: Meta Out ::#{inspect(ref)}")
              process_loop(p.node, p.us, p.ds, p.state, p.meta_state)
          after
            1000 ->
              raise "OPR :: Timeout waiting for meta-level response to meta message #{inspect(m)}."
          end
        else
          process_loop(node, upstreams, downstreams, state, meta_state)
        end

      {:initialize} ->
        # log("OPR: Initializing (ignoring)")

        if node.meta != nil do
          source = node.meta
          # ref = make_ref()()
          meta_event = {%{meta_state: meta_state, pid: self(), state: state, node: node, us: upstreams, ds: downstreams}, :init_opr}
          # log_meta("OPR :: INIT :: Meta In  ::#{inspect(ref)}")
          Creek.Source.Subject.next(source, meta_event)

          receive do
            {p = %{}, :ok} ->
              # log_meta("OPR :: INIT :: Meta Out ::#{inspect(ref)}")
              process_loop(node, p.us, p.ds, state, p.meta_state)
          after
            1000 ->
              raise "OPR :: Timeout waiting for meta-level response to initialize meta."
          end
        else
          process_loop(node, upstreams, downstreams, state, meta_state)
        end

      {:next, value, from = {from_pid, _from_gate, gate}} ->
        # log("OPR: next #{inspect(value)} from #{inspect(from_pid)} @ gate #{inspect(gate)}")

        if node.meta != nil do
          # META
          # ////////////////////////////////////////////////////////////////////
          source = node.meta
          # ref = make_ref()()
          meta_event = {%{meta_state: meta_state, pid: self(), state: state, gate: gate, node: node, us: upstreams, ds: downstreams}, :next, value, from}
          # log_meta("OPR :: NEXT :: Meta In  ::#{inspect(ref)}")
          Creek.Source.Subject.next(source, meta_event)

          receive do
            {p = %{}, :ok} ->
              # log_meta("OPR :: NEXT :: Meta Out ::#{inspect(ref)}")
              process_loop(node, p.us, p.ds, p.state, p.meta_state)
          after
            1000 ->
              raise "OPR :: Timeout waiting for meta-level response to next meta."
          end

          # NO META
          # ////////////////////////////////////////////////////////////////////
        else
          response = node.impl.next(node, state, gate, value)

          case response do
            {state, :next, value} ->
              effects_next(value, downstreams, self())
              process_loop(node, upstreams, downstreams, state, meta_state)

            {state, :skip} ->
              process_loop(node, upstreams, downstreams, state, meta_state)

            {state, :final, value} ->
              effects_next(value, downstreams, self())
              # effects_complete(nil, downstreams, upstreams, from_pid)
              # Tell everyone to delete us as a downstream.
              propagate_upstream({:delete_downstream}, upstreams, self())
              # Tell all downstreams that we completed.
              propagate_downstream({:complete}, downstreams, self())

              send_self({:finish}, self())

              process_loop(node, upstreams, downstreams, state, meta_state)

            _ ->
              nil
              # warn("OPR: next invalid return value!")
          end
        end

      {:complete, from = {from_pid, from_gate, to_gate}} ->
        warn("OPR: Received complete from, #{inspect(from_pid)} @ gate #{inspect(to_gate)}")

        # if Enum.count(upstreams) < 2 do
        if node.meta != nil do
          source = node.meta
          # ref = make_ref()()
          meta_event = {%{meta_state: meta_state, pid: self(), state: state, gate: to_gate, node: node, us: upstreams, ds: downstreams}, :complete, from}
          # log_meta("OPR :: COMP :: Meta In  ::#{inspect(ref)}")
          Creek.Source.Subject.next(source, meta_event)

          receive do
            {p = %{}, :ok} ->
              # log_meta("OPR :: COMP :: Meta Out ::#{inspect(ref)}")
              process_loop(node, p.us, p.ds, p.state, p.meta_state)
          after
            1000 ->
              raise "OPR :: Timeout waiting for meta-level response to complete meta}."
          end
        else
          response = node.impl.complete(node, state)

          case response do
            # The operator really wants to quit, even though other upstreams are stil alive.
            {state, :complete} ->
              send_self({:finish})
              effects_complete(from, downstreams, upstreams, self())
              process_loop(node, upstreams, downstreams, state, meta_state)

            # The operator goes on without the completed upstream.
            # If it is the only upstream the complete is sent down.
            {state, :continue} ->
              # Remove the upstream, as it has completed.
              upstreams = Enum.filter(upstreams, &(&1 != {from_pid, from_gate, to_gate}))
              effects_continue(downstreams, upstreams, self())
              process_loop(node, upstreams, downstreams, state, meta_state)

            r ->
              err("OPR: Complete callback returned invalid response #{inspect(r)}")
              process_loop(node, upstreams, downstreams, state, meta_state)
          end
        end

      # else
      # upstreams = Enum.filter(upstreams, &(&1 != {from_pid, from_gate, to_gate}))
      # process_loop(node, upstreams, downstreams, state, meta_state)
      # end

      m ->
        warn("OPR: Message not understood: #{inspect(m)}")
        process_loop(node, upstreams, downstreams, state, meta_state)
    end
  end

  ##############################################################################
  # Sink #######################################################################
  ##############################################################################

  def sink(node, upstreams) do
    Process.flag :trap_exit, true

    if node.meta != nil do
      # We spawn the META graph of this process.
      source = Creek.Source.subject(description: "meta subject")
      sink = Creek.Sink.tap(self())
      Creek.Runtime.run(node.meta, [src: source, snk: sink], meta: true)
      sink_loop(%{node | meta: source}, upstreams, node.arg, nil)
    else
      sink_loop(node, upstreams, node.arg, nil)
    end
  end

  def sink_loop(node, upstreams, state, meta_state) do
    receive do
      ###############
      # Bookkeeping #
      ###############

      {:offer_meta, meta_dag, args} ->
        if meta_dag != nil do
          source = Creek.Source.subject(description: "meta subject")
          sink = Creek.Sink.tap(self())
          Creek.Runtime.run(meta_dag, [src: source, snk: sink] ++ args)
          node = %{node | meta: source}
          sink_loop(node, upstreams, state, meta_state)
        else
          sink_loop(node, upstreams, state, meta_state)
        end

      {:add_upstream, upstream = {from_pid, from_gate, to_gate}} ->
        Process.monitor(from_pid)
        # warn("SNK: Adding upstream #{inspect(upstream)} (current: #{inspect(upstreams)}")
        sink_loop(node, [upstream | upstreams], state, meta_state)

      {:finish} ->
        warn("SNK: Finished (#{inspect(self())})")
        :finished

      {:DOWN, _ref, _, pid, _} ->
        warn("SNK: Node down")
        sink_loop(node, upstreams, state, meta_state)

      #################
      # Base Protocol #
      #################
      {:meta_message, m, from} ->
        # debug_meta(("SNK: (#{node.name}) Direct Meta Message :: #{inspect(m)}")

        if node.meta != nil do
          source = node.meta
          # ref = make_ref()()
          meta_event = {%{meta_state: meta_state, pid: self(), state: state, gate: nil, node: node, us: upstreams, ds: []}, :meta, m, from}
          # log_meta("SNK :: INIT :: Meta In  ::#{inspect(ref)} -> #{inspect(source)}")
          Creek.Source.Subject.next(source, meta_event)

          receive do
            {p = %{}, :ok} ->
              # log_meta("SNK :: INIT :: Meta Out ::#{inspect(ref)}")
              sink_loop(node, p.us, p.state, p.meta_state)
          after
            1000 ->
              raise "SNK:: Timeout waiting for meta-level response to meta message #{inspect(m)}."
          end
        else
          sink_loop(node, upstreams, state, meta_state)
        end

      {:initialize} ->
        # log("SNK: Initializing")

        if node.meta != nil do
          source = node.meta
          # ref = make_ref()()
          meta_event = {%{meta_state: meta_state, pid: self(), state: state, gate: nil, node: node, us: upstreams, ds: []}, :init_snk}
          # log_meta("SNK :: INIT :: Meta In  ::#{inspect(ref)} -> #{inspect(source)}")
          Creek.Source.Subject.next(source, meta_event)

          receive do
            {p = %{}, :ok} ->
              # log_meta("SNK :: INIT :: Meta Out ::#{inspect(ref)}")
              sink_loop(node, p.us, p.state, p.meta_state)
          after
            2000 ->
              raise "SNK:: Timeout waiting for meta-level response to initialize."
          end
        else
          sink_loop(node, upstreams, state, meta_state)
        end

      # Next values always come from upstream.
      {:next, value, from = {from_pid, _from_gate, to_gate}} ->
        # log("SNK: next #{inspect(value)} from #{inspect(from_pid)} at gate #{to_gate}")

        if node.meta != nil do
          source = node.meta
          # ref = make_ref()()
          meta_event = {%{meta_state: meta_state, pid: self(), state: state, gate: to_gate, node: node, us: upstreams, ds: []}, :next, value, from}
          # log_meta("SNK :: NEXT :: Meta In  ::#{inspect(ref)}")
          Creek.Source.Subject.next(source, meta_event)

          receive do
            {p = %{}, :ok} ->
              # log_meta("SNK :: NEXT :: Meta Out ::#{inspect(ref)}")
              sink_loop(node, p.us, p.state, p.meta_state)
          after
            5000 ->
              raise "SNK:: Timeout waiting for meta-level response to next meta."
          end
        else
          response = node.impl.next(node, state, to_gate, value)

          case response do
            {state, :ok} ->
              sink_loop(node, upstreams, state, meta_state)

            {state, :complete} ->
              effects_complete(nil, [], upstreams, self())
              sink_loop(node, upstreams, state, meta_state)

            _ ->
              nil
              # warn("SNK: next invalid return value!")
          end
        end

      {:complete, from = {_from_pid, _from_gate, to_gate}} ->
        # log("SNK: Received complete from, #{inspect(from_pid)} at gate #{to_gate}")

        if node.meta != nil do
          source = node.meta
          # ref = make_ref()()
          meta_event = {%{meta_state: meta_state, pid: self(), state: state, gate: to_gate, node: node, us: upstreams, ds: []}, :complete, from}
          # log_meta("SNK :: COMP :: Meta In  ::#{inspect(ref)}")
          Creek.Source.Subject.next(source, meta_event)

          receive do
            {p = %{}, :ok} ->
              # log_meta("SNK :: COMP :: Meta Out ::#{inspect(ref)}")
              sink_loop(node, p.us, p.state, p.meta_state)
          after
            1000 ->
              raise "SNK:: Timeout waiting for meta-level response to complete meta."
          end
        else
          response = node.impl.complete(node, state)

          # This complete is the last upstream.
          # That means that after this one there will be no more upstreams.
          case response do
            {state, :continue} ->
              if Enum.count(upstreams) < 2 do
                effects_complete(from, [], upstreams, self())
                sink_loop(node, upstreams, state, meta_state)
              else
                # Remove the upstream, as it has completed.
                upstreams = Enum.filter(upstreams, &(&1 != from))
                sink_loop(node, upstreams, state, meta_state)
              end

            {state, :complete} ->
              effects_complete(from, [], upstreams, self())
              sink_loop(node, upstreams, state, meta_state)

            _ ->
              nil
              warn("SNK: complete invalid return value!")
          end
        end

      m ->
        nil
        warn("SNK: Message not understood: #{inspect(m)}")
    end
  end

  ##############################################################################
  # Side effects  ##############################################################
  ##############################################################################

  def effects_next(value, downstreams, frompid) do
    propagate_downstream({:next, value}, downstreams, frompid)
  end

  def effects_complete(from, downstreams, upstreams, frompid) do
    propagate_upstream({:delete_downstream}, Enum.filter(upstreams, &(&1 != from)), frompid)
    propagate_downstream({:complete}, downstreams, frompid)
    send_self({:finish}, frompid)
  end

  def effects_continue(downstreams, upstreams, frompid) do
    if upstreams == [] do
      propagate_downstream({:complete}, downstreams, frompid)
      send_self({:finish}, frompid)
    end
  end

  def effects_initialize_source(self) do
    send_self({:tick}, self)
  end

  def effects_tick_value(frompid, value, downstreams) do
    send_self({:tick}, frompid)
    propagate_downstream({:next, value}, downstreams, frompid)
  end

  ##############################################################################
  # Runtime Meta DSL  ##########################################################
  ##############################################################################

  def put_meta_state(p, state) do
    %{p | meta_state: state}
  end

  def propagate_upstream_meta(message, upstreams, frompid) do
    for {to_pid, from_gate, to_gate} <- upstreams do
      send(to_pid, {:meta_message, message, {frompid, from_gate, to_gate}})
    end
  end

  ##############################################################################
  # Helpers ####################################################################
  ##############################################################################

  def propagate_downstream(message, downstreams, frompid) do
    for {to_pid, from_gate, to_gate} <- downstreams do
      send(to_pid, Tuple.append(message, {frompid, from_gate, to_gate}))
    end
  end

  def propagate_upstream(message, upstreams, frompid) do
    for {to_pid, from_gate, to_gate} <- upstreams do
      warn("OPR SENDING UPSTREAM #{inspect(Tuple.append(message, {frompid, from_gate, to_gate}))}")
      send(to_pid, Tuple.append(message, {frompid, from_gate, to_gate}))
    end
  end

  def send_self(message, pid \\ self()) do
    send(pid, message)
  end
end
