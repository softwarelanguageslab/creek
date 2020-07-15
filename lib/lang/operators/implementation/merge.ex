defmodule Creek.Operator.Merge do
  def next(_this, state, _from, value) do
    {state, :next, value}
  end

  def complete(_this, state) do
    {state, :continue}
  end
end
