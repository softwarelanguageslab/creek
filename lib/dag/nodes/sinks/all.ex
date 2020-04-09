defmodule Creek.Node.Sink.All do
  def complete(state, _downstream) do
    {:done, state}
  end

  def next(_, value, state, _downstream) do
    {:continue, state ++ [value]}
  end
end
