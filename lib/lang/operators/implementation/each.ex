defmodule Creek.Sink.Each do
  def next(_this, proc, _from, value) do
    # Process.sleep(3000)
    proc.(value)
    {proc, :ok}
  end

  def complete(_this, proc) do
    {proc, :complete}
  end
end
