defmodule Creek.Node.Sink.Head do
  def next(_this, state, _from, value) do
    {state, {:yield, value}}
  end

  def complete(_this, state) do
    {state, {:yield, state}}
  end
end
