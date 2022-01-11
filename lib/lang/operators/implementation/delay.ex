defmodule Creek.Source.Delay do
  def tick(_this, state) do
    case state do
      {timeout, value} ->
        Process.sleep(timeout)
        {nil, :tick, value}

      nil ->
        {state, :complete}
    end
  end

  def initialize(_this, state) do
    {state, :initialized}
  end
end
