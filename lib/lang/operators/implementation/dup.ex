defmodule Creek.Operator.Dup do
  def next(_this, state, _from, value) do
    {state, :next, value}
  end

  def complete(_this, state) do
    {state, :complete}
  end
end
