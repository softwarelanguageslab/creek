defmodule Creek.Meta do
  def install(dag, meta_module) do
    # Iterate over all the nodes in the DAG.
    MutableGraph.map_vertices(dag, fn node ->
      case node.type do
        :sink ->
          %{node | meta: meta_module.sink()}

        :operator ->
          %{node | meta: meta_module.operator()}

        :source ->
          %{node | meta: meta_module.source()}
      end
    end)
  end
end
