defmodule Creek.Node.Source.Single do
  def tick(this, state) do
    if state != nil do
      value = state
      {nil, {:next, value}}
    else
      {state, :complete}
    end
  end

  def subscribe(_this, state, _from) do
    {state, :continue}
  end
end
