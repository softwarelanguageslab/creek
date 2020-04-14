defmodule Creek.Node.Source.FromList do
  def subscribe(values, downstream) do
    # for testing purposes
    Process.sleep(500)

    for d <- downstream do
      for v <- values do
        send(d, {:next, v})
      end

      send(d, {:complete, self()})
    end
  end
end
