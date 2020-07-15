defmodule Creek.App do
  use Application

  @impl true
  def start(_type, _args) do
    Creek.Server.start_link()
  end
end
