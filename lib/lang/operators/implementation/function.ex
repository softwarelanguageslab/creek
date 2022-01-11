defmodule Creek.Source.Function do
  def tick(_this, state) do
    Process.sleep(1000)
    {state, :tick, state.()}
  end

  def initialize(_this, state) do
    {state, :initialized}
  end
end
