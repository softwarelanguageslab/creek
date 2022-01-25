defmodule Creek.Debugger.SocketHandler do
  @behaviour :cowboy_websocket

  def init(request, _state) do
    state = %{registry_key: request.path}
    {:cowboy_websocket, request, state}
  end

  defp sanitize_op(o) do
    %{o | name: o.name, arg: inspect(o.arg), opts: inspect(o.opts), pid: inspect(o.pid), impl: inspect(o.impl), meta: nil}
  end
  defp sanitize_edge(edge = %{from: f, fidx: fidx, to: to, tidx: tidx}) do
    %{edge | from: sanitize_op(f), to: sanitize_op(to)}
  end

  defp sanitize_edges(edges) do
    Enum.map(edges, &sanitize_edge/1)
  end

  def websocket_init(state) do
    Phoenix.PubSub.subscribe(Creek.PubSub, "streams:new")
    Phoenix.PubSub.subscribe(Creek.PubSub, "incoming")

    streams = Creek.Server.get_streams()
            |> Enum.map(fn {stream_id, edges} ->
              {stream_id, sanitize_edges(edges)}
            end)
          |> Enum.into(%{})

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
    message = %{message: "new_stream", id: id, stream: sanitize_edges(stream)}
    {[{:text, Jason.encode!(message)}], state}
  end

  def websocket_info({:incoming, pid, value}, state) do
    IO.inspect "emit"
    message = %{message: "incoming", pid: inspect(pid), value: inspect(value)}

    {[{:text, Jason.encode!(message)}], state}
  end

  # def websocket_info(info, state) do
  #   IO.inspect(info)
  #   {[], state}
  # end

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
      # %{"message" => "stream_details", "stream" => stream}
    else
      IO.puts("Stream not found")
    end
  end

  defp process_command(other) do
    IO.puts("Command not understood: #{inspect(other)}")
  end
end
