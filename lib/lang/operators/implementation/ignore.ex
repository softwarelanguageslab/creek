defmodule Creek.Sink.Ignore do
  def next(_this, nil, _from, _value) do
    {nil, :ok}
  end

  def complete(_this, state) do
    {state, :complete}
  end
end
