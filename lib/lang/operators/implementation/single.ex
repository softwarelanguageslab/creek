defmodule Creek.Source.Single do
  def tick(_this, state) do
    if state != nil do
      value = state
      {nil, :tick, value}
    else
      {state, :complete}
    end
  end

  def initialize(_this, state) do
    {state, :initialized}
  end
end
