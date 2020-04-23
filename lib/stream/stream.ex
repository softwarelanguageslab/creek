defmodule Creek.Stream do
  @doc """
  Connect a sink to a running stream.
  This means the stream must be extendable (e.g., fanout).
  """
  def extend(stream, source, sink) do
    # Ensure the source is a DAG.
    source = ensure_dag(source)

    # Spawn each node in the graph.
    spawned_dag = MutableGraph.map_vertices(source, &spawn_node/1)
    [output] = MutableGraph.sink_vertices(spawned_dag)

    # Put the links between the processes in the graph.
    MutableGraph.map_vertices(spawned_dag, fn process ->
      # Add the downstreams.
      MutableGraph.vertices_from(spawned_dag, process)
      |> Enum.map(fn d ->
        send(process, {:add_downstream, d})
      end)

      # Add the upstreams.
      MutableGraph.vertices_to(spawned_dag, process)
      |> Enum.map(fn u ->
        send(process, {:add_upstream, u})
      end)
    end)

    # Get the source of the stream.
    [source] = MutableGraph.source_vertices(spawned_dag)

    # Spawn the sink.
    {ivar, spawned_sink} = spawn_sink(sink, output)

    # Add the sink as a downstream node to the sink of the graph.
    send(output, {:add_downstream, spawned_sink})

    # Connect the source of the dag and the sink of the stream.
    stream_sink = stream.sink

    send(source, {:add_upstream, stream_sink})
    send(stream_sink, {:add_downstream, source})

    # Return the ivar.
    %{ivar: ivar, source: source, sink: spawned_sink, graph: spawned_dag}
  end

  @doc """
  When the sink is a process id it's typically because of higher order streams.
  One running process want's to intercept all the streams output.
  """
  def run(source, sink) when is_pid(sink) do
    # Ensure the source is a DAG.
    source = ensure_dag(source)

    # Spawn each node in the graph.
    spawned_dag = MutableGraph.map_vertices(source, &spawn_node/1)
    [output] = MutableGraph.sink_vertices(spawned_dag)

    # Put the links between the processes in the graph.
    MutableGraph.map_vertices(spawned_dag, fn process ->
      # Add the downstreams.
      MutableGraph.vertices_from(spawned_dag, process)
      |> Enum.map(fn d ->
        send(process, {:add_downstream, d})
      end)

      # Add the upstreams.
      MutableGraph.vertices_to(spawned_dag, process)
      |> Enum.map(fn u ->
        send(process, {:add_upstream, u})
      end)
    end)

    # Get the source of the stream.
    sources = MutableGraph.source_vertices(spawned_dag)

    # Add the sink as a downstream node to the sink of the graph.
    send(output, {:add_downstream, sink})
    send(sink, {:add_upstream, output})

    # Send the subscription to the source stream.
    send(output, {:subscribe, sink})

    %{ivar: nil, source: sources, sink: sink, graph: spawned_dag}
  end

  @doc """
  Runs a dag without returning a future to resolve the result.
  """
  def run(source, sink) do
    # Ensure the source is a DAG.
    source = ensure_dag(source)

    # Spawn each node in the graph.
    spawned_dag = MutableGraph.map_vertices(source, &spawn_node/1)
    [output] = MutableGraph.sink_vertices(spawned_dag)

    # Put the links between the processes in the graph.
    MutableGraph.map_vertices(spawned_dag, fn process ->
      # Add the downstreams.
      MutableGraph.vertices_from(spawned_dag, process)
      |> Enum.map(fn d ->
        send(process, {:add_downstream, d})
      end)

      # Add the upstreams.
      MutableGraph.vertices_to(spawned_dag, process)
      |> Enum.map(fn u ->
        send(process, {:add_upstream, u})
      end)
    end)

    # Get the source of the stream.
    sources = MutableGraph.source_vertices(spawned_dag)

    # Spawn the sink.
    {ivar, spawned_sink} = spawn_sink(sink, output)

    # Add the sink as a downstream node to the sink of the graph.
    send(output, {:add_downstream, spawned_sink})
    send(spawned_sink, {:add_upstream, output})

    # Start the subscription on the sink.
    send(spawned_sink, :init)

    # Return the ivar.
    %{ivar: ivar, source: sources, sink: spawned_sink, graph: spawned_dag}
  end

  @doc """
  Blocks until the stream resolves.
  """
  def get(%{ivar: ivar}) do
    Ivar.get(ivar)
  end

  # -----------------------------------------------------------------------------
  # Helpers

  defp spawn_node(node) do
    case node.type do
      :source ->
        spawn(fn ->
          Creek.Stream.Process.source(node, MapSet.new())
        end)

      :operator ->
        spawn(fn ->
          Creek.Stream.Process.process(node, MapSet.new(), MapSet.new())
        end)
    end
  end

  defp spawn_sink(node, source) do
    ivar = Ivar.new()

    pid =
      spawn(fn ->
        Creek.Stream.Process.sink(node, ivar, source)
      end)

    {ivar, pid}
  end

  defp ensure_dag(source) do
    case source do
      %MutableGraph{} -> source
      _ -> MutableGraph.new() |> MutableGraph.add_vertex(source)
    end
  end
end
