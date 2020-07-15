defmodule PingPing do
  use Creek

  # Behaviour for an operator.
  fragment operator as map(fn {{:operator, op}, dag, it} ->
                         new_op =
                           case op.name do
                             "map" ->
                               %{
                                 op
                                 | arg: fn x ->
                                     IO.puts("pingping")
                                     x
                                   end
                               }

                             __ ->
                               op
                           end

                         {new_op, dag, it}
                       end)

  # Behaviour for an edge.
  fragment edge as map(fn {{:edge, from, fidx, to, toidx}, dag, it} ->
                     {{:edge, from, fidx, to, toidx}, dag, it}
                   end)

  # Behaviour for naming an operator.
  fragment name as map(fn {{:name_it, name}, dag, it} ->
                     {{:name_it, name}, dag, it}
                   end)

  ##############################################################################
  fragment edge_filter as filter(fn event ->
                            match?({{:edge, _, _, _, _}, _, _}, event)
                          end)

  fragment operator_filter as filter(fn event ->
                                match?({{:operator, _}, _, _}, event)
                              end)

  fragment name_filter as filter(fn event ->
                            match?({{:name_it, _}, _, _}, event)
                          end)

  ##############################################################################

  fragment edge_proceed as map(fn {evt, dag, _it} ->
                             {:edge, from, idxf, to, idxt} = evt
                             from = GatedDag.vertices(dag) |> Enum.filter(&(&1.ref == from)) |> hd()
                             to = GatedDag.vertices(dag) |> Enum.filter(&(&1.ref == to)) |> hd()

                             new_dag = GatedDag.add_edge(dag, from, idxf, to, idxt)
                             {new_dag, evt}
                           end)

  fragment op_proceed as map(fn {op, dag, _it} ->
                           new_dag = GatedDag.add_vertex(dag, op, op.in, op.out)
                           {new_dag, op}
                         end)

  fragment name_proceed as map(fn {name, dag, it} ->
                             {:name_it, name} = name
                             op = GatedDag.vertices(dag) |> Enum.filter(&(&1 == it)) |> hd()

                             new_dag = GatedDag.map_vertices(dag, fn v -> if v == op, do: %{op | ref: name}, else: v end)

                             {new_dag, name}
                           end)

  ##############################################################################

  fragment edge_handler as edge_filter() ~> edge() ~> edge_proceed()
  fragment op_handler as operator_filter() ~> operator() ~> op_proceed()
  fragment name_handler as name_filter() ~> name() ~> name_proceed()
  ##############################################################################
  # 1--> 2
  fragment branches as dup() ~> (edge_handler() ||| dup() ~> (op_handler() ||| name_handler()) ~> merge()) ~> merge()

  ##############################################################################

  # Full DAG
  defdag metadag(src, snk) do
    src ~> branches() ~> snk
  end
end
