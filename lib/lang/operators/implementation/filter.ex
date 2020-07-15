defmodule Creek.Operator.Filter do
  def next(this, state, _from, value) do
    if this.arg.(value) do
      {state, :next, value}
    else
      {state, :skip}
    end
  end

  def complete(_this, state) do
    {state, :complete}
  end
end
