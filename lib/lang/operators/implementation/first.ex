defmodule Creek.Sink.First do
  def next(_this, {ivar, state}, _from, value) do
    if ivar != nil do
      Ivar.put(ivar, value)
    end
    {{ivar, state}, :complete}
  end

  def complete(_this, {ivar, state}) do
    if ivar != nil do
      Ivar.put(ivar, nil)
    end
    {{ivar, state}, :complete}
  end
end
