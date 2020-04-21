defmodule Creek.Node.Source.Single do
  def subscribe(value, downstream) do
    Process.sleep(100)

    for d <- downstream do
      # send(d, {:next, value})
      send(self(), {:send, d, {:next, value}})
      # send(d, {:complete, self()})
      send(self(), {:send, d, {:complete, self()}})
    end
  end
end
