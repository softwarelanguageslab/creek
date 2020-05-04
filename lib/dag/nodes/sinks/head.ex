defmodule Creek.Node.Sink.Head do
  def next(this, state, _from, value) do
    {state, {:yield, value}}
  end

  def complete(this, state) do
    {state, {:yield, state}}
  end
end
