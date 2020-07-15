defmodule Creek.BenchmarkApp do
  @moduledoc """
  This example is the application that will be used to benchmark.

  The function for each operator is defined as the identity function. Elixir generates new lambdas for every operator, even if they are identical (which is normal).
  Therefore we have separately defined the identity function to avoid defining hundreds of lambdas and slowing down the compiler.

  The graph is one long DAG with map operators without branches.

  The parameters for creating the DAG are fetched from the environment:
     * NODES: define the amount of nodes the DAG should have (NODES > 0)
     * VALS: define the amount of values should be pushed through the DAG.


  """
  use Creek
  require Logger

  execution(IdentityMeta)

  def identity(x), do: x

  @doc """
  Creates the graph at compiletime of the DAGs, based on the environment value of amount of nodes.
  """
  def gen_graph() do
    {nodes, _} = System.get_env("NODES") |> Integer.parse()

    if nodes > 1 do
      1..nodes
      |> Enum.reduce(map(&identity/1), fn i, acc -> acc ~> map(&identity/1) end)
    else
      map(&identity/1)
    end
  end

  @doc """
  Define the fragment that holds the graph using the generator function.
  """
  fragment mapper as gen_graph()

  @doc """
  Define the closed DAG using the fragment from above.
  """
  defdag test(src, snk) do
    src ~> mapper() ~> snk
  end

  def main() do
    {values, _} = System.get_env("VALS") |> Integer.parse()
    source = Creek.Source.range(0, values)

    ivar = Ivar.new()
    sink = Creek.Sink.last(ivar)

    Creek.Runtime.run(test(), [src: source, snk: sink], dot: true)

    ivar
    |> Ivar.get()
  end
end
