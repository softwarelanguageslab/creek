defmodule Creek.Compiler do
  ##############################################################################
  # Internal DAG to eventlist

  def compile_dag_to_event_list(gdag, _opts \\ []) do
    operators =
      operators_in_dag(gdag)
      |> Enum.flat_map(fn operator ->
        [{:operator, %{operator | ref: nil}}, {:name_it, operator.ref}]
      end)

    operators ++ edges_for_graph(gdag)
  end

  ##############################################################################
  # Helpers

  @doc """
  Returns a list of all the operators in the internal DAG.
  """
  def operators_in_dag(gdag) do
    gdag
    |> GatedDag.breadth_first_reduce(&(&2 ++ [&1]), [])
  end

  @doc """
  Returns all the edges between operators, ignoring the edges between plugs and operators.
  """
  def edges_for_graph(gdag) do
    # breadth_first_reduce(gdag, proc, acc)

    proc = fn vertex, acc ->
      GatedDag.edges_from(gdag, vertex)
      |> Enum.map(fn {from, fidx, to, toidx} -> {:edge, from.ref, fidx, to.ref, toidx} end)
      |> Enum.reduce(acc, fn edge, edges -> edges ++ [edge] end)
    end

    GatedDag.breadth_first_reduce(
      gdag,
      proc,
      []
    )
  end
end
