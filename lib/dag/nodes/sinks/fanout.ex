defmodule Creek.Node.Sink.FanOut do
  def complete(state, downstream) do
    {:continue, state}
  end

  def next(_, value, state, downstream) do
    for d <- downstream, do: send(d, {:next, value})
    {:continue, state}
  end
end
