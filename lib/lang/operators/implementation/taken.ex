defmodule Creek.Operator.TakeN do
  def next(this, n, _from, value) do
    case n do
      1 ->
        Process.sleep(1000)
        {0, :final, value}

      n ->
        {n - 1, :next, value}
    end
  end

  def complete(_this, state) do
    {state, :complete}
  end
end
