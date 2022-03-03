defmodule Creek.Source.Gatherer do
  @warn true
  def next(subj, value) do
    send(subj, {:next, value})
  end

  def complete(subj) do
    send(subj, {:complete, nil})
  end

  def gatherer(node, downstreams, upstreams) do
    gather_loop(node, downstreams, upstreams, node.arg)
  end

  def gather_loop(node, downstreams, upstreams, state) do
    receive do
      ###############
      # Bookkeeping #
      ###############
      {:offer_meta, _, _} ->
        gather_loop(node, downstreams, upstreams, state)

      {:add_upstream, upstream} ->
        {from_pid, from_gate, _} = upstream
        warn("GATHERER: Adding upstream #{inspect(upstream)} (current: #{inspect(upstreams)}")
        Process.monitor(from_pid)
        gather_loop(node, downstreams, [upstream | upstreams], state)

        {:add_downstream, downstream} ->
          {pid, from_gate, _} = downstream
          Process.monitor(pid)
        warn("GATHERER: Adding downstream #{inspect(downstream)} (current: #{inspect(downstreams)}")
        gather_loop(node, [downstream | downstreams], upstreams, state)

      {:delete_downstream, downstream} ->
        warn("GATHERER: Removing downstream #{inspect(downstream)} (current: #{inspect(downstreams)}")
        new_downstreams = Enum.filter(downstreams, &(downstream != &1))

        if new_downstreams == [] do
          send_self({:finish})
          propagate_upstream({:delete_downstream}, upstreams, self())
          warn("GATHERER: No downstreams left anymore.")
        else
          warn("GATHERER: Still downstreams left: #{inspect(new_downstreams)}")
        end

        gather_loop(node, new_downstreams, upstreams, state)

      {:finish} ->
        log("GATHERER: Finished #{node.name}")
        # If a source receives a finish it simply finishes.
        # The finish message *always* comes from the process itself.
        # Itonly has one downstream and that received the complete message.
        :finished

      #################
      # Base Protocol #
      #################
      {:initialize} ->
        gather_loop(node, downstreams, upstreams, state)

      {:next, value, from} ->
        # log("GATHERER: Nexting #{inspect(value)}")
        propagate_downstream({:next, value}, downstreams)
        gather_loop(node, downstreams, upstreams, state)

      {:complete, from} ->
        # A gatherer does not complete hen all its upstreams are finished.
        # It only finishes if al lits downstreams are finished.
        if from != nil do
          upstreams = Enum.filter(upstreams, &(&1 != from))
          gather_loop(node, downstreams, upstreams, state)
        else
          propagate_downstream({:complete}, downstreams)
          propagate_upstream({:delete_downstream}, upstreams)
        end

      m ->
        log("GATHERER: Message not understood: #{inspect(m)}")
    end
  end

  def propagate_downstream(message, downstreams) do
    for {to_pid, from_gate, to_gate} <- downstreams do
      IO.puts("Sending #{inspect(Tuple.append(message, {self(), from_gate, to_gate}))} to #{inspect(to_pid)}")
      send(to_pid, Tuple.append(message, {self(), from_gate, to_gate}))
    end
  end

  def propagate_upstream(message, upstreams) do
    for {to_pid, from_gate, to_gate} <- upstreams do
      IO.puts("Sending #{inspect(Tuple.append(message, {self(), from_gate, to_gate}))} to #{inspect(to_pid)}")
      send(to_pid, Tuple.append(message, {self(), from_gate, to_gate}))
    end
  end

  def send_self(message) do
    send(self(), message)
  end

  @log true
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
    if @log do
      IO.puts(IO.ANSI.red() <> "ERR  #{inspect(self())}: #{message}" <> IO.ANSI.reset())
    end
  end

  def propagate_downstream(message, downstreams, frompid) do
    for {to_pid, from_gate, to_gate} <- downstreams do
      send(to_pid, Tuple.append(message, {frompid, from_gate, to_gate}))
    end
  end

  def propagate_upstream(message, upstreams, frompid) do
    for {to_pid, from_gate, to_gate} <- upstreams do
      send(to_pid, Tuple.append(message, {frompid, from_gate, to_gate}))
    end
  end

  def send_self(message, pid \\ self()) do
    send(pid, message)
  end
end
