defmodule Creek.Sink.All do
  def next(_this, {ivar, state}, _from, value) do
    # Process.sleep(3000)
    new_state = state ++ [value]
    {{ivar, new_state}, :ok}
  end

  def complete(_this, {ivar, state}) do
    Ivar.put(ivar, state)
    {{ivar, state}, :complete}
  end
end
