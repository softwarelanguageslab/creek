defmodule Creek.Operator.Map do
  def next(this, state, _from, value) do
    new_value = this.arg.(value)
    {state, :next, new_value}
  end

  def complete(_this, state) do
    {state, :complete}
  end
end
