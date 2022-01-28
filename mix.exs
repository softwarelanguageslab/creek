defmodule Creek.MixProject do
  use Mix.Project

  def project do
    [
      app: :creek,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Creek.App, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:mutable_graph, git: "ssh://christophe@call-cc.be:/home/christophe/repositories/libmutablegraph.git", branch: "master"},
      # {:mutable_graph, path: "/home/christophe/code/libmutablegraph"},
      {:gated_dag, git: "ssh://christophe@call-cc.be:/home/christophe/repositories/gated-dag.git", branch: "master"},
      # {:gated_dag, path: "/home/christophe/code/gated-dag"},
      {:ivar, git: "ssh://christophe@call-cc.be:/home/christophe/repositories/Ivar.git", branch: "master"},
      {:benchee, "~> 1.0", only: :dev},
      {:cowboy, "~> 2.9"},
      {:plug, "~> 1.12.1"},
      {:plug_cowboy, "~> 2.5.2"},
      {:jason, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 2.0"}
    ]
  end
end
