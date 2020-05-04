defmodule Creek.Node.Sink.All do
  def next(this, state, _from, value) do
    new_state = state ++ [value]
    {new_state, :skip}
  end

  def complete(this, state) do
    {state, {:yield, state}}
  end
end
