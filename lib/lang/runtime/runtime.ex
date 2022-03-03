defmodule Creek.Runtime do
  alias Process, as: Proc
  import Process
  alias Creek.{Operator, Runtime.Process}
  use Creek

  @spec run(GatedDag.t(), [{atom(), pid()}], [{atom(), any}]) :: GatedDag.t()
  @doc """
  Given a gated dag and a keywordlist of actors, turnst he DAG into a stream.
  """
  def run(gdag, actors, opts \\ []) do
    gdag =
      if is_function(gdag) do
        gdag.()
      else
        gdag
      end

    if Keyword.has_key?(opts, :debug) do
      IO.inspect(GatedDag.vertices(gdag), pretty: true, limit: 4)
    end

    actors_alive? =
      GatedDag.vertices(gdag)
      |> Enum.filter(fn v ->
        case v do
          %Operator{name: "actor_src", label: label, ref: ref} ->
            true

          %Operator{name: "actor_snk", label: label, ref: ref} ->
            true

          _ ->
            false
        end
      end)
      |> Enum.map(fn v ->
        case v do
          %Operator{name: "actor_src", label: label, ref: ref} ->
            node(Keyword.fetch!(actors, label)) |> :rpc.call(:erlang, :is_process_alive, [Keyword.fetch!(actors, label)])

          %Operator{name: "actor_snk", label: label, ref: ref} ->
            node(Keyword.fetch!(actors, label)) |> :rpc.call(:erlang, :is_process_alive, [Keyword.fetch!(actors, label)])

          _ ->
            true
        end
      end)
      |> Enum.all?()

    if not actors_alive? do
      IO.puts "Not spawning stream because actors are not online"
      nil
    else
      # Register the stream in the Stream repository.
      stream_id = Creek.Server.gen_id()
      operators = GatedDag.vertices(gdag) |> Enum.map(fn o -> Map.from_struct(o) end)

      if Keyword.has_key?(opts, :dot) do
        dot = GatedDag.to_dot(gdag, fn x -> "#{x.name}" end)
        File.write!("unspawned_dag.dot", dot)
      end

      gdag =
        GatedDag.map_vertices(gdag, fn vertex ->
          %{vertex | meta_sink: Keyword.get(opts, :meta_sink, []), meta_in: Keyword.get(opts, :meta_in, [])}
        end)

      # Spawn all the operators into their own actor.
      spawned_dag =
        GatedDag.map_vertices(gdag, fn vertex ->
          case vertex do
            %Operator{name: "actor_src", label: label, ref: ref} ->
              if Keyword.has_key?(actors, label) do
                pid = Keyword.fetch!(actors, label)
                send(pid, {:offer_meta, vertex.meta, vertex.meta_sink})
                Creek.Server.add_operator(ref, %{vertex: vertex, pid: pid})
                Process.new(pid, ref)
              else
                raise "DAG expects source actor for #{label}. Cannot run DAG with given arguments."
              end

            %Operator{name: "actor_snk", label: label, ref: ref} ->
              if Keyword.has_key?(actors, label) do
                pid = Keyword.fetch!(actors, label)
                send(pid, {:offer_meta, vertex.meta, vertex.meta_sink})
                Creek.Server.add_operator(ref, %{vertex: vertex, pid: pid})
                Process.new(pid, ref)
              else
                raise "DAG expects sink actor for #{label}. Cannot run DAG with given arguments."
              end

            %Operator{ref: ref} ->
              pid = spawn_operator(vertex)
              proc = Process.new(pid, ref)
              Creek.Server.add_operator(ref, %{vertex: vertex, pid: pid})
              proc
          end
        end)

      if not Keyword.has_key?(opts, :meta) do
        vertices = GatedDag.vertices(spawned_dag)

        with_pids =
          operators
          |> Enum.map(fn operator ->
            proc =
              vertices
              |> Enum.filter(fn p -> p.ref == operator.ref end)
              |> hd()

            Map.put(operator, :pid, proc.pid)
          end)

        edges =
          GatedDag.edges(gdag)
          |> Enum.map(fn {from, fidx, to, tidx} ->
            new_from = with_pids |> Enum.filter(fn o -> o.ref == from.ref end) |> hd()
            new_to = with_pids |> Enum.filter(fn o -> o.ref == to.ref end) |> hd()
            {new_from, fidx, new_to, tidx}
          end)

        Creek.Server.add_stream(stream_id, edges)
      end

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
  end

  ##############################################################################
  # Helpers

  def spawn_operator(operator) do
    spawn(fn -> Creek.Runtime.Process.process(operator, [], []) end)
  end
end
