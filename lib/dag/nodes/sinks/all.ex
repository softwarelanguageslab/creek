defmodule Creek.Node.Sink.All do
  def next(_this, state, _from, value) do
    new_state = state ++ [value]
    {new_state, :skip}
  end

  def complete(_this, state) do
    {state, {:yield, state}}
  end
end
