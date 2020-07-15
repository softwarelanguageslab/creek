defmodule Creek.Sink.Last do
  def next(_this, {ivar, _state}, _from, value) do
    {{ivar, value}, :ok}
  end

  def complete(_this, {ivar, state}) do
    Ivar.put(ivar, state)
    {{ivar, state}, :complete}
  end
end
