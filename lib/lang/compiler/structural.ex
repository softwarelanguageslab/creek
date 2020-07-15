defmodule Structural do
  defmacro __using__(_options) do
    quote do
      use Creek

      # Behaviour for an operator.
      fragment default_operator(
                 as filter(fn event ->
                      match?({{:operator, _}, _, _}, event)
                    end)
                    ~> map(fn {{:operator, op}, dag, it} ->
                      {{:operator, op}, dag, it}
                    end)
               )

      fragment default_name(
                 as filter(fn event ->
                      match?({{:name_it, _}, _, _}, event)
                    end)
                    ~> map(fn {{:name_it, name}, dag, it} ->
                      {{:name_it, name}, dag, it}
                    end)
               )

      fragment default_edge(
                 as filter(fn event ->
                      match?({{:edge, _, _, _, _}, _, _}, event)
                    end)
               )

      fragment proceed as map(fn {evt, dag, it} ->
                            case evt do
                              {:edge, from, idxf, to, idxt} ->
                                from = GatedDag.vertices(dag) |> Enum.filter(&(&1.ref == from)) |> hd()
                                to = GatedDag.vertices(dag) |> Enum.filter(&(&1.ref == to)) |> hd()

                                new_dag = GatedDag.add_edge(dag, from, idxf, to, idxt)
                                {new_dag, evt}

                              {:name_it, name} ->
                                op = GatedDag.vertices(dag) |> Enum.filter(&(&1 == it)) |> hd()

                                new_dag = GatedDag.map_vertices(dag, fn v -> if v == op, do: %{op | ref: name}, else: v end)

                                {new_dag, name}

                              {:operator, op} ->
                                new_dag = GatedDag.add_vertex(dag, op, op.in, op.out)
                                {new_dag, op}

                              _ ->
                                raise "Invalid event: #{inspect(evt, pretty: true)}"
                            end
                          end)
    end
  end
end
