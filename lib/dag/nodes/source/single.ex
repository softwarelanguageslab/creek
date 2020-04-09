defmodule Creek.Node.Source.Single do
  def subscribe(value, downstream) do
    # for testing purposes
    Process.sleep(500)

    for d <- downstream do
      send(d, {:next, value})
      send(d, {:complete, self()})
    end
  end
end
