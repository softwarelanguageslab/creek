defmodule Creek.Node.Operator.Flatten do
  import Creek.Stream

  def next(_proc, value, downstream) do
    [downstream] = MapSet.to_list(downstream)

    # The value is a DAG, so we realize it into our downstream.
    value
    |> run(downstream)
  end

  def complete(from, upstream, downstream) do
    # Dispose the upstream, as it's done.
    send(from, :dispose)

    IO.puts "Flatten its upstream: "
    # Notify our downstream.
    if MapSet.to_list(upstream) == [from] do
      for d <- downstream, do: send(d, {:complete, self()})
    end
  end
end
