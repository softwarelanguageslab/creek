defmodule Creek.Source.List do
  def tick(_this, state) do
    # Process.sleep(:rand.uniform(10000))

    if state != [] do
      [value | rest] = state
      # Process.sleep(2000)
      {rest, :tick, value}
    else
      {state, :complete}
    end
  end

  @spec initialize(any, any) :: {any, :continue}
  def initialize(_this, state) do
    {state, :initialized}
  end
end
