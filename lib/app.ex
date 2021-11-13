defmodule Creek.App do
  use Application

  @impl true
  def start(_type, _args) do
    Creek.Server.start_link()
  end

  def test() do
    fst = Creek.Operator.map(:x) |> Creek.Operator.ensure_dag()
    snd = Creek.Operator.map(:b) |> Creek.Operator.ensure_dag()
    left = GatedDag.link_dags(fst, snd)
    dot = GatedDag.to_dot(left, fn x -> "#{inspect(x.arg)}" end)
    File.write!("left.dot", dot)

    fst = Creek.Operator.map(:c) |> Creek.Operator.ensure_dag()
    snd = Creek.Operator.map(:d) |> Creek.Operator.ensure_dag()
    right = GatedDag.link_dags(fst, snd)
    dot = GatedDag.to_dot(right, fn x -> "#{inspect(x.arg)}" end)
    File.write!("right.dot", dot)

    dag = GatedDag.merge_dags(left, right)
    dot = GatedDag.to_dot(dag, fn x -> "#{inspect(x.arg)}" end)
    File.write!("merged.dot", dot)
  end
end
