defmodule Creek.Operator.Fold do
  def next(_this, {proc, state}, _from, value) do
    new_state = proc.(value, state)
    {{proc, state}, :next, new_state}
  end

  def complete(_this, state) do
    {state, :complete}
  end
end
