defmodule Creek.Sink.Ignore do
  def next(_this, pid, _from, _value) do
    {pid, :ok}
  end

  def complete(_this, pid) do
    if pid != nil do
      send(pid, :done)
    end

    {pid, :complete}
  end
end
