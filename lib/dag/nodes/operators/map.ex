defmodule Creek.Node.Operator.Map do
  def next(proc, value, downstream) do
    for d <- downstream do
      send(self(), {:send, d, {:next, proc.(value)}})
    end
  end

  def complete(from, upstream, downstream) do
    # We ignore all the complete messages, except the last.
    IO.puts("MapSet.to_list(upstream) == [from] = #{MapSet.to_list(upstream) == [from]}")

    if MapSet.to_list(upstream) == [from] do
      # Notify our downstream.
      if MapSet.to_list(upstream) == [from] do
        for d <- downstream, do: send(self(), {:send, d, {:complete, self()}})
      end
    end

    # Dispose the upstream, as it's done.
    send(self(), {:send, from, :dispose})
  end
end
