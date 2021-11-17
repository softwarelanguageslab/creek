defmodule Creek.Sink.Funnel do
  def next(_this, subject, _from, value) do
    Creek.Source.Subject.next(subject, value)
    {subject, :ok}
  end

  @spec complete(any, {Ivar.t(), any}) :: {{Ivar.t(), any}, :complete}
  def complete(this, pid) do
    {pid, :continue}
  end
end
