defmodule Creek.Node.Sink.All do
  def next(this, state, _from, value) do
    {state ++ [value], :skip}
  end

  def complete(this, state) do
    {state, {:yield, state}}
  end
end
