defmodule Creek.Node.Sink.Head do
  def complete(_state, _downstream) do
    {:done, nil}
  end

  def next(_, value, _, _downstream) do
    {:done, value}
  end
end
