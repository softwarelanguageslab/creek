defmodule Creek.App do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Plug.Cowboy.child_spec(
      #   scheme: :http,
      #   plug: Creek.Debugger.Router,
      #   options: [
      #     dispatch: dispatch(),
      #     port: 4000
      #   ]
      # ),
      # Registry.child_spec(
      #   keys: :duplicate,
      #   name: Registry.Creek.DebuggerApp
      # ),
      {Phoenix.PubSub, name: Creek.PubSub},
      Creek.Server
    ]

    # Creek.Server.start_link()

    opts = [strategy: :one_for_one, name: Creek.App]
    Supervisor.start_link(children, opts)
  end

  defp dispatch do
    [
      {:_,
       [
         {"/ws/[...]", Creek.Debugger.SocketHandler, []},
         {"/assets/[...]", :cowboy_static, {:dir, "debugger/assets"}},
         {:_, Plug.Cowboy.Handler, {Creek.Debugger.Router, []}}
       ]}
    ]
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
