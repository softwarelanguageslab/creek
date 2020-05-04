defmodule Creek.Meta do
  def install(%MutableGraph{} = dag, meta_module) do
    # Iterate over all the nodes in the DAG.
    MutableGraph.map_vertices(dag, fn node ->
      IO.puts(node.type)

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

  def install(node, meta_module) do
    case node.type do
      :sink ->
        %{node | meta: meta_module.sink()}

      :operator ->
        %{node | meta: meta_module.operator()}

      :source ->
        %{node | meta: meta_module.source()}
    end
  end
end
