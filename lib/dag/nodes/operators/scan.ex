defmodule Creek.Node.Operator.Scan do
  def next(this, state, _from, value) do
    new_state = this.arg.(state, value)
    {new_state, {:next, new_state}}
  end

  def complete(_this, state) do
    {state, :complete}
  end

  def error(_this, state, err) do
    {:state, {:error, err}}
  end
end
