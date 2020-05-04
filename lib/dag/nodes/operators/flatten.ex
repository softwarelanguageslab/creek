defmodule Creek.Node.Operator.Flatten do
  import Creek.Stream

  def next(this, state, _from, value) do
    [downstream] = this.downstream
    # Proxy all the elements to the downstream node directly.
    value
    |> run(downstream)

    {state, :skip}
  end

  def complete(this, state) do
    {state, :complete}
  end
end
