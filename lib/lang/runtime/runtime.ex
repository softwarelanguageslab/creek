defmodule Creek.Runtime do
  import Process
  alias Creek.{Operator, Runtime.Process}

  @spec run(GatedDag.t(), [{atom(), pid()}], [{atom(), any}]) :: GatedDag.t()
  @doc """
  Given a gated dag and a keywordlist of actors, turnst he DAG into a stream.
  """
  def run(gdag, actors, opts \\ []) do
    if Keyword.has_key?(opts, :debug) do
      IO.inspect(GatedDag.vertices(gdag), pretty: true, limit: 4)
    end

    if Keyword.has_key?(opts, :dot) do
      dot = GatedDag.to_dot(gdag, fn x -> "#{x.name}" end)
      File.write!("unspawned_dag.dot", dot)
    end

    # Spawn all the operators into their own actor.
    spawned_dag =
      GatedDag.map_vertices(gdag, fn vertex ->
        case vertex do
          %Operator{name: "actor_src", label: label, ref: ref} ->
            if Keyword.has_key?(actors, label) do
              pid = Keyword.fetch!(actors, label)
              send(pid, {:offer_meta, vertex.meta})
              Process.new(pid, ref)
              Process.new(Keyword.fetch!(actors, label), ref)
            else
              raise "DAG expects source actor for #{label}. Cannot run DAG with given arguments."
            end

          %Operator{name: "actor_snk", label: label, ref: ref} ->
            if Keyword.has_key?(actors, label) do
              pid = Keyword.fetch!(actors, label)
              send(pid, {:offer_meta, vertex.meta})
              Process.new(pid, ref)
            else
              raise "DAG expects sink actor for #{label}. Cannot run DAG with given arguments."
            end

          %Operator{ref: ref} ->
            Process.new(spawn_operator(vertex), ref)
        end
      end)

    # Add the up- and downstreams in all the operators.
    # The unique identification of an upstream is its pid + outputgate + input gate.
    # This allows us to have one actor to be the input to two input gates of a downstream.
    spawned_dag
    |> GatedDag.vertices()
    |> Enum.map(fn vertex ->
      GatedDag.edges_from(spawned_dag, vertex)
      |> Enum.map(fn {from, idxf, to, idxt} ->
        send(from.pid, {:add_downstream, {to.pid, idxf, idxt}})
      end)

      GatedDag.edges_to(spawned_dag, vertex)
      |> Enum.map(fn {from, idxf, to, idxt} ->
        send(to.pid, {:add_upstream, {from.pid, idxf, idxt}})
      end)
    end)

    # Initialize all the operators.
    spawned_dag
    |> GatedDag.vertices()
    |> Enum.map(fn vertex ->
      send(vertex.pid, {:initialize})
    end)

    if Keyword.has_key?(opts, :debug) do
      IO.inspect(GatedDag.vertices(spawned_dag), pretty: true, limit: 5)
      dot = GatedDag.to_dot(spawned_dag, fn x -> "#{inspect(x.pid)}" end)
      File.write!("spawned_dag.dot", dot)
    end

    spawned_dag
  end

  ##############################################################################
  # Helpers

  def spawn_operator(operator) do
    spawn(fn -> Creek.Runtime.Process.process(operator, [], []) end)
  end
end
