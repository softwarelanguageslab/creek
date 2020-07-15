defmodule Creek.Operator.Zip do
  def next(_this, state, from, value) do
    state = Map.update(state, from, [value], &(&1 ++ [value]))

    # Implement and semantics.
    case state do
      %{0 => [x | xs], 1 => [y | ys]} ->
        {%{0 => xs, 1 => ys}, :next, {x, y}}

      _ ->
        {state, :skip}
    end
  end

  def complete(_this, state) do
    {state, :complete}
  end
end
