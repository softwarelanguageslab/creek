defmodule Creek.Node.Source.FromList do
  def tick(_this, state) do
    if state != [] do
      new_state = tl(state)
      value = hd(state)
      {new_state, {:next, value}}
    else
      {state, :complete}
    end
  end

  def subscribe(_this, state, _from) do
    {state, :continue}
  end
end
