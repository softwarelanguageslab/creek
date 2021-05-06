defmodule Creek.Source.Range do
  def tick(_this, state) do
    # Process.sleep(:rand.uniform(10000))
    {a, b, stepsize} = state

    if b == :infinity or a < b do
      {{a + stepsize, b, stepsize}, :tick, a}
    else
      {state, :complete}
    end
  end

  def initialize(_this, state) do
    {state, :initialized}
  end
end
