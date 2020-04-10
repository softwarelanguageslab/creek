defmodule Creek.Wiring do
  require Logger

  @doc """
  Connect two graphs together.
  """
  def left ~> right, do: connect_dag(left, right)

  defp connect_dag(left, right) do
    l_dag = ensure_dag(left)
    r_dag = ensure_dag(right)

    # Copy over all the edges from the right dag into the left dag.
    m_dag = merge_graphs(l_dag, r_dag)

    m_dag
  end

  @doc """
  Merge two dags together
  """
  def lefts ~>> right do
    merge(lefts, right)
  end

  defp merge([leftx, lefty], right) do
    l_dagx = ensure_dag(leftx)
    l_dagy = ensure_dag(lefty)
    r_dag = ensure_dag(right)

    threeway_merge(l_dagx, l_dagy, r_dag)
  end

  # -----------------------------------------------------------------------------
  # Helpers

  # Ensures that a given value is a DAG. If the value is a node it is turned into
  # a graph with a single node.
  defp ensure_dag(node) do
    cond do
      is_node?(node) -> MutableGraph.new() |> MutableGraph.add_vertex(node)
      true -> node
    end
  end

  # Checks if the given value is a node or a graph. Returns true if the value is
  # a node, false otherwise.
  defp is_node?(node) do
    case node do
      %{} -> true
      _ -> false
    end
  end

  # Merges two graphs together. Assume that each graph has one sink and one source.
  defp merge_graphs(left, right) do
    # Determine the sink and source node for each graph, where they will be connected.
    l_sink = MutableGraph.sink_vertices(left) |> hd()
    r_source = MutableGraph.source_vertices(right) |> hd()

    # Merge the graphs together.
    right
    |> MutableGraph.edges()
    |> Enum.reduce(left, fn {from, to}, left ->
      MutableGraph.add_edge(left, from, to)
    end)
    |> MutableGraph.add_edge(l_sink, r_source)
  end

  defp threeway_merge(leftx, lefty, right) do
    # Determine the sink and source node for each graph, where they will be connected.
    lx_sink = MutableGraph.sink_vertices(leftx) |> hd()
    ly_sink = MutableGraph.sink_vertices(lefty) |> hd()
    r_source = MutableGraph.source_vertices(right) |> hd()

    # Merge the graphs together.
    right =
      leftx
      |> MutableGraph.edges()
      |> Enum.reduce(right, fn {from, to}, left ->
        MutableGraph.add_edge(left, from, to)
      end)
      |> MutableGraph.add_edge(lx_sink, r_source)

    # Merge the graphs together.
    lefty
    |> MutableGraph.edges()
    |> Enum.reduce(right, fn {from, to}, left ->
      MutableGraph.add_edge(left, from, to)
    end)
    |> MutableGraph.add_edge(ly_sink, r_source)
  end
end
