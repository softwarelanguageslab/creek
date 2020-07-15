defmodule Creek.Sink.First do
  def next(_this, {ivar, state}, _from, value) do
    Ivar.put(ivar, value)
    {{ivar, state}, :complete}
  end

  def complete(_this, {ivar, state}) do
    Ivar.put(ivar, nil)
    {{ivar, state}, :complete}
  end
end
