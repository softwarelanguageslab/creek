defmodule Creek.Source.Range do
  def tick(_this, state) do
    # Process.sleep(:rand.uniform(10000))
    {a, b} = state

    if b == :infinity or a < b do
      # IO.puts "Emitting #{a}"
      {{a + 1, b}, :tick, a}
    else
      {state, :complete}
    end
  end

  @spec initialize(any, any) :: {any, :continue}
  def initialize(_this, state) do
    {state, :initialized}
  end
end
