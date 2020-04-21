defmodule Creek.Node.Operator.Map do
  def next(proc, value, downstream) do
    for d <- downstream, do: send(d, {:next, proc.(value)})
  end

  def complete(from, upstream, downstream) do
    # Dispose the upstream, as it's done.
    # send(from, :dispose)
    send(self(), {:send, from, :dispose})

    # Notify our downstream.
    if MapSet.to_list(upstream) == [from] do
      # send(d, {:complete, self()})
      for d <- downstream, do: send(self(), {:send, d, {:complete, self()}})
    end
  end
end
