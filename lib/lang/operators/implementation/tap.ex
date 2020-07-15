defmodule Creek.Sink.Tap do
  def next(_this, pid, _from, value) do
    send(pid, value)
    {pid, :ok}
  end

  @spec complete(any, {Ivar.t(), any}) :: {{Ivar.t(), any}, :complete}
  def complete(_this, pid) do
    # send(pid, :complete)
    {pid, :complete}
  end
end
