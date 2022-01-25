defmodule Creek.Debugger.SocketHandler do
  @behaviour :cowboy_websocket

  def init(request, _state) do
    state = %{registry_key: request.path}
    {:cowboy_websocket, request, state}
  end

  def websocket_init(state) do
    Phoenix.PubSub.subscribe(Creek.PubSub, "streams:new")

    streams = Creek.Server.get_streams()

    payload = Jason.encode!(%{"message" => "streamlist", "streams" => streams})

    {[{:text, payload}], state}
  end

  def websocket_handle({:text, data}, state) do
    payload = Jason.decode!(data)
    response = process_command(payload)
    payload = {:text, Jason.encode!(response)}
    {[payload], state}
  end

  def websocket_info({:new_stream, id, stream}, state) do
    message = %{message: "new_stream", id: id, stream: stream}
    {[{:text, Jason.encode!(message)}], state}
  end

  def websocket_info(info, state) do
    IO.inspect(info)
    {[], state}
  end

  defp process_command(%{"message" => "stream_details", "stream_id" => stream_id}) do
    streams = Creek.Server.get_streams()

    if Map.has_key?(streams, stream_id) do
      stream = Map.get(streams, stream_id)
      %{"message" => "stream_details", "stream" => stream}
    else
      IO.puts("Stream not found")
    end
  end

  defp process_command(%{"message" => "operator_details", "stream_id" => stream_id, "operator_id" => operator_id}) do
    streams = Creek.Server.get_streams()

    if Map.has_key?(streams, stream_id) do
      stream = Map.get(streams, stream_id)
      IO.inspect(stream)
      # %{"message" => "stream_details", "stream" => stream}
    else
      IO.puts("Stream not found")
    end
  end

  defp process_command(other) do
    IO.puts("Command not understood: #{inspect(other)}")
  end
end
