defmodule Creek.Source.Range do
  def tick(_this, state) do
    # Process.sleep(:rand.uniform(10000))
    {a, b, stepsize, delay} = state

    if b == :infinity or a <= b do
      if delay > 0 do
        Process.sleep(delay)
      end

      {{a + stepsize, b, stepsize, delay}, :tick, a}
    else
      {state, :complete}
    end
  end

  def initialize(_this, state) do
    {state, :initialized}
  end
end
