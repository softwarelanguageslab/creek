defmodule Creek.Node.Operator.Filter do
  def next(this, state, _from, value) do
    if this.arg.(value) do
      new_value = this.arg.(value)
      {state, {:next, new_value}}
    else
      {state, :skip}
    end
  end

  def complete(this, state) do
    {state, :complete}
  end
end
