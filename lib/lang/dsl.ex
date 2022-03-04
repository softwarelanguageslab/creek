defmodule Creek.DSL do
  ##############################################################################
  # Macros for Meta

  defmacro fuse(first, second) do
    quote do
      first_arg = unquote(first).arg
      second_arg = unquote(second).arg

      new_arg = fn x -> second_arg.(first_arg.(x)) end

      unquote(second)
      |> Map.put(:arg, new_arg)
    end
  end

  defmacro delete(node) do
    quote do
      dag = var!(dag)
      dag = GatedDag.del_vertex(dag, unquote(node))
      var!(dag) = dag
    end
  end

  defmacro insert(node) do
    quote do
      dag = var!(dag)
      dag = GatedDag.add_vertex(dag, unquote(node), unquote(node).in, unquote(node).out)
      var!(dag) = dag
    end
  end

  defmacro connect(a, agate, b, bgate) do
    quote do
      dag = var!(dag)
      dag = GatedDag.add_edge(dag, unquote(a), unquote(agate), unquote(b), unquote(bgate))
      # dag = GatedDag.add_edge(dag, unquote(b), unquote(bgate), unquote(a), unquote(agate))
      var!(dag) = dag
    end
  end

  defmacro fuse(first, second, f) do
    quote do
      first_arg = unquote(first).arg
      second_arg = unquote(second).arg

      new_arg = unquote(f).(first_arg, second_arg)

      unquote(second)
      |> Map.put(:arg, new_arg)
    end
  end

  defmacro swap!(first, new) do
    quote do
      dag = var!(dag)
      dag = GatedDag.del_vertex(dag, unquote(first))
      dag = GatedDag.add_vertex(dag, unquote(new), unquote(new).in, unquote(new).out)
      var!(dag) = dag
    end
  end

  defmacro fetch!(ref) do
    quote do
      case GatedDag.vertices(var!(dag)) |> Enum.filter(fn op -> op.ref == unquote(ref) end) do
        [] -> nil
        [x] -> x
      end
    end
  end

  @spec inputs(any) :: {{:., [], [:vertices_to | {any, any, any}, ...]}, [], [...]}
  defmacro inputs(ref) do
    quote do
      GatedDag.vertices_to(var!(dag), unquote(ref))
    end
  end

  ##############################################################################
  # Macros

  defmacro structure(exp) do
    quote do
      def metadag(:generated) do
        unquote(exp)
      end

      alias :metadag, as: Meta
    end
  end

  defmacro structure(a, b) do
    quote do
      def metadag(:generated) do
        [unquote(a), unquote(b)]
      end

      alias :metadag, as: Meta
    end
  end

  defmacro execution(exp) do
    quote do
      alias unquote(exp), as: RuntimeMeta
    end
  end

  defmacro fragment({name, _, [{:as, _, [exp]}]}) do
    quote do
      def unquote(name)() do
        Creek.Operator.ensure_dag(unquote(exp))
      end
    end
  end

  defmacro dag({name, _, [{:as, _, [exp]}]}) do
    quote do
      def unquote(name)() do
        Creek.Operator.ensure_dag(unquote(exp))
      end
    end
  end

  defmacro let({name, _, [{:as, _, [exp]}]}) do
    quote do
      var!(unquote(Macro.var(name, __MODULE__))) = fn -> unquote(exp) end
    end
  end

  defmacro deploy_module(m_atom, f_atom, args, opts \\ []) do
    IO.puts "Deploying module DAG"
    quote do
      dict =
        unquote(args)
        |> Enum.reduce(%{}, fn {label, value}, dict ->
          Map.put(dict, label, value)
        end)

      dag = apply(unquote(m_atom), unquote(f_atom), [dict])
      Creek.Runtime.run(dag, unquote(args), unquote(opts))
    end
  end

  defmacro deploy(dagfunc, args, opts \\ []) do
    {f_atom, _, _} = dagfunc

    quote do
      dict =
        unquote(args)
        |> Enum.reduce(%{}, fn {label, value}, dict ->
          Map.put(dict, label, value)
        end)

      dag = apply(__MODULE__, unquote(f_atom), [dict])
      Creek.Runtime.run(dag, unquote(args), unquote(opts))
    end
  end


  defmacro dag({name, _, args}, do: exp) do
    # Each parameter is reassigned to a dummy Creek.Operator.
    # These are replaced in the end when its known weather they are a source or sink.
    dummy_assigns =
      args
      |> Enum.map(fn {name, _, _} -> name end)
      |> Enum.map(fn var ->
        quote do
          dum = dummy(unquote(var)) |> Creek.Operator.ensure_dag()
          original_value = var!(consts) |> Map.get(unquote(var))
          var!(unquote(Macro.var(var, __MODULE__))) = dum
        end
      end)

    reassignments =
      args
      |> Enum.map(fn {name, _, _} -> name end)
      |> Enum.map(fn var ->
        quote do
          dum = dummy(unquote(var)) |> Creek.Operator.ensure_dag()
          original_value = var!(consts) |> Map.get(unquote(var))

          var!(unquote(Macro.var(var, __MODULE__))) =
            if Enum.member?(var!(unquote(Macro.var(:dummies, __MODULE__))), unquote(var)) do
              dum
            else
              original_value
            end
        end
      end)

    reassignments_total = Enum.count(reassignments)

    quote do
      fn ->
        var!(consts) = %{}
        var!(unquote(Macro.var(:dummies, nil))) = %{}
        name = inspect(Atom.to_string(__MODULE__) <> "." <> Atom.to_string(unquote(name)) <> "/#{unquote(reassignments_total)}")

        # Check if the DAG has been compiled yet.
        cached = Creek.Server.fetch(name)

        # IO.inspect var!(consts), label: "consts"
        # if cached do
        if cached do
          cached
        else
          # Create the internal DAG.
          unquote_splicing(dummy_assigns)
          d = unquote(exp)
          {ds, internal_dag} = remap_dummies(d)
          var!(unquote(Macro.var(:dummies, nil))) = ds
          constants = unquote(reassignments_total) - Enum.count(ds)
          unquote_splicing(reassignments)

          d = unquote(exp)
          {ds, internal_dag} = remap_dummies(d)

          if ensure_closed(internal_dag) != true do
            raise "DAG #{name} is not closed!"
          end

          result =
            if alias!(Meta) == :metadag do
              compiled_dag =
                case metadag(:generated) do
                  xs when is_list(xs) ->
                    xs
                    |> Enum.reduce(internal_dag, fn mdag, internal_dag ->
                      events = compile_dag_to_event_list(internal_dag)
                      compiled_dag = stream_events_to_dag(events, mdag)
                      compiled_dag
                    end)

                  x ->
                    events = compile_dag_to_event_list(internal_dag)
                    compiled_dag = stream_events_to_dag(events, x)
                    compiled_dag
                end

              # dot = GatedDag.to_dot(internal_dag, fn x -> "#{x.name}" end)
              # File.write!("internal_dag.dot", dot)
              # dot = GatedDag.to_dot(compiled_dag, fn x -> "#{x.name}" end)
              # File.write!("compiled_dag.dot", dot)
              compiled_dag
            else
              # dot = GatedDag.to_dot(internal_dag, fn x -> "#{x.name}" end)
              # File.write!("internal_dag.dot", dot)
              internal_dag
            end

          # Inject the meta bethaviour.
          result =
            IO.inspect alias!(RuntimeMeta), label: "runtime meta alias"
            if alias!(RuntimeMeta) != nil do
              GatedDag.map_vertices(result, fn vertex ->
                case vertex.type do
                  :operator ->
                    %{vertex | meta: alias!(RuntimeMeta).operator()}

                  :source ->
                    %{vertex | meta: alias!(RuntimeMeta).source()}

                  :sink ->
                    %{vertex | meta: alias!(RuntimeMeta).sink()}

                  :actor_source ->
                    %{vertex | meta: alias!(RuntimeMeta).source()}

                  :actor_sink ->
                    %{vertex | meta: alias!(RuntimeMeta).sink()}

                  # Actors are regular actor implementations to which we cannot graft a meta.
                  :actor ->
                    vertex
                end
              end)
            else
              result
            end

          if constants == 0 do
            Creek.Server.store_compiled(name, result)
          end

          result
        end
      end
    end
  end

  defmacro defdag({name, _, args}, do: exp) do
    # Each parameter is reassigned to a dummy Creek.Operator.
    # These are replaced in the end when its known weather they are a source or sink.
    dummy_assigns =
      args
      |> Enum.map(fn {name, _, _} -> name end)
      |> Enum.map(fn var ->
        quote do
          dum = dummy(unquote(var)) |> Creek.Operator.ensure_dag()
          original_value = var!(consts) |> Map.get(unquote(var))
          var!(unquote(Macro.var(var, __MODULE__))) = dum
        end
      end)

    reassignments =
      args
      |> Enum.map(fn {name, _, _} -> name end)
      |> Enum.map(fn var ->
        quote do
          dum = dummy(unquote(var)) |> Creek.Operator.ensure_dag()
          original_value = var!(consts) |> Map.get(unquote(var))

          var!(unquote(Macro.var(var, __MODULE__))) =
            if Enum.member?(var!(unquote(Macro.var(:dummies, __MODULE__))), unquote(var)) do
              dum
            else
              original_value
            end
        end
      end)

    reassignments_total = Enum.count(reassignments)

    quote do
      # (unquote_splicing(args)) do
      def unquote(name)(var!(unquote(Macro.var(:consts, nil))) \\ %{}) do
        var!(unquote(Macro.var(:dummies, nil))) = %{}
        name = inspect(Atom.to_string(__MODULE__) <> "." <> Atom.to_string(unquote(name)) <> "/#{unquote(reassignments_total)}")

        # Check if the DAG has been compiled yet.
        cached = Creek.Server.fetch(name)

        # IO.inspect var!(consts), label: "consts"
        # if cached do
        if cached do
          cached
        else
          # Create the internal DAG.
          unquote_splicing(dummy_assigns)
          d = unquote(exp)
          {ds, internal_dag} = remap_dummies(d)
          var!(unquote(Macro.var(:dummies, nil))) = ds
          constants = unquote(reassignments_total) - Enum.count(ds)
          unquote_splicing(reassignments)

          d = unquote(exp)
          {ds, internal_dag} = remap_dummies(d)

          if ensure_closed(internal_dag) != true do
            raise "DAG #{name} is not closed!"
          end

          result =
            if alias!(Meta) == :metadag do
              compiled_dag =
                case metadag(:generated) do
                  xs when is_list(xs) ->
                    xs
                    |> Enum.reduce(internal_dag, fn mdag, internal_dag ->
                      events = compile_dag_to_event_list(internal_dag)
                      compiled_dag = stream_events_to_dag(events, mdag)
                      compiled_dag
                    end)

                  x ->
                    events = compile_dag_to_event_list(internal_dag)
                    compiled_dag = stream_events_to_dag(events, x)
                    compiled_dag
                end

              # dot = GatedDag.to_dot(internal_dag, fn x -> "#{x.name}" end)
              # File.write!("internal_dag.dot", dot)
              # dot = GatedDag.to_dot(compiled_dag, fn x -> "#{x.name}" end)
              # File.write!("compiled_dag.dot", dot)
              compiled_dag
            else
              # dot = GatedDag.to_dot(internal_dag, fn x -> "#{x.name}" end)
              # File.write!("internal_dag.dot", dot)
              internal_dag
            end

          # Inject the meta bethaviour.
          result =
            if alias!(RuntimeMeta) != nil do
              GatedDag.map_vertices(result, fn vertex ->
                case vertex.type do
                  :operator ->
                    %{vertex | meta: alias!(RuntimeMeta).operator()}

                  :source ->
                    %{vertex | meta: alias!(RuntimeMeta).source()}

                  :sink ->
                    %{vertex | meta: alias!(RuntimeMeta).sink()}

                  :actor_source ->
                    %{vertex | meta: alias!(RuntimeMeta).source()}

                  :actor_sink ->
                    %{vertex | meta: alias!(RuntimeMeta).sink()}

                  # Actors are regular actor implementations to which we cannot graft a meta.
                  :actor ->
                    vertex
                end
              end)
            else
              result
            end

          if constants == 0 do
            Creek.Server.store_compiled(name, result)
          end

          result
        end
      end
    end
  end

  ##############################################################################
  # User-facing functions

  def idag_l ~> idag_r do
    GatedDag.link_dags(idag_l |> Creek.Operator.ensure_dag(), idag_r |> Creek.Operator.ensure_dag())
  end

  def idag_l ||| idag_r do
    dag_r =
      idag_r
      |> Creek.Operator.ensure_dag()
      |> GatedDag.map_vertices(fn v ->
        case v do
          %Creek.Operator{name: "dummy"} ->
            %{v | ref: Creek.Server.gen_sym()}

          _ ->
            v
        end
      end)

    dag_l =
      idag_l
      |> Creek.Operator.ensure_dag()
      |> GatedDag.map_vertices(fn v ->
        case v do
          %Creek.Operator{name: "dummy"} ->
            %{v | ref: Creek.Server.gen_sym()}

          _ ->
            v
        end
      end)

    GatedDag.merge_dags(dag_l, dag_r)
  end

  ##############################################################################
  # Helpers

  @doc """
  Given a GatedDAG ensures that it is closed.
  If a DAG has unconnected in- or outputs the compiler will reject it.
  """
  def ensure_closed(%GatedDag{} = gdag) do
    GatedDag.dangling_inputs(gdag) == [] and GatedDag.dangling_outputs(gdag) == []
  end

  @doc """
  Given a GatedDag representing a stream, remaps each actorentry to either a source or a sink, depending on where it's located in the dag.
  """
  def remap_dummies(%GatedDag{} = gdag) do
    # We need to find all the vetices that are dummies.

    dummies =
      GatedDag.vertices(gdag)
      |> Enum.filter(fn operator ->
        operator.name == "dummy"
      end)

    dag =
      dummies
      |> Enum.reduce(gdag, fn dummy, gdag ->
        case {GatedDag.edges_from(gdag, dummy), GatedDag.edges_to(gdag, dummy)} do
          # Source actor has no incoming edges, and one outgoing.
          {[{from, _idxf, to, idxt}], []} ->
            v = Creek.Operator.actor_src() |> Map.put(:label, from.label)
            gdag = GatedDag.del_vertex(gdag, from)
            gdag = GatedDag.add_vertex(gdag, v, 0, 1)
            GatedDag.add_edge(gdag, v, 0, to, idxt)

          {[], [{from, idxf, to, _idxt}]} ->
            v = Creek.Operator.actor_snk() |> Map.put(:label, to.label)
            gdag = GatedDag.del_vertex(gdag, to)
            gdag = GatedDag.add_vertex(gdag, v, 1, 0)
            GatedDag.add_edge(gdag, from, idxf, v, 0)

          {_, _} ->
            raise "Using `#{dummy.label}` source or sink as input *and* output. This is not a valid dag!"
        end
      end)

    dummy_names = dummies |> Enum.map(fn d -> d.label end)
    {dummy_names, dag}
  end
end
