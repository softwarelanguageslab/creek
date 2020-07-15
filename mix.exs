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
      {:mutable_graph, git: "ssh://git@gitlab.call-cc.be:2200/research/libmutablegraph.git"},
      {:gated_dag, git: "ssh://git@gitlab.call-cc.be:2200/research/gated-dag.git", commit: "722db2a"},
      {:ivar, git: "ssh://git@gitlab.call-cc.be:2200/research/ivar.git", branch: "master"},
      {:benchee, "~> 1.0", only: :dev}
    ]
  end
end
