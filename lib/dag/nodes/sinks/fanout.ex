defmodule Creek.Node.Sink.FanOut do
  def next(this, state, _from, value) do
    {state, {:next, value}}
  end

  def complete(this, state) do
    {state, {:complete, state}}
  end
end
