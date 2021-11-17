defmodule Creek.Sink.Ignore do
  def next(_this, pid, _from, _value) do
    {pid, :ok}
  end

  def complete(_this, pid) do
    send(pid, :done)
    {pid, :complete}
  end
end
