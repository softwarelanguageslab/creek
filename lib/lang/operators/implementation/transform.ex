defmodule Creek.Operator.Transform do
  def next(_this, {state, proc}, _from, value) do
    {state, new_value} = proc.(value, state)
    new_state = {state, proc}
    {new_state, :next, new_value}
  end

  def complete(_this, state) do
    {state, :complete}
  end
end
