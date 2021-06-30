defmodule Creek.Operator.ZipLatest do
  def next(_this, state, from, value) do
    state = Map.put(state, from, value)

    # Implement or semantics, drop stale.
    case state do
      %{0 => x, 1 => y} ->
        {%{0 => x, 1 => y}, :next, {x, y}}

      _ ->
        {state, :skip}
    end
  end

  def complete(_this, state) do
    {state, :complete}
  end
end
