# https://stackoverflow.com/questions/29668635/how-can-we-easily-time-function-calls-in-elixir
defmodule Benchmark do
  require Logger

  def round(x, n) do
    p = :math.pow(10.0, n)
    trunc(x * p) / p
  end

  @doc """
  Executes the function and returns how many milliseconds it took to execute it.
  """
  def measure(function) do
    function
    |> :timer.tc()
    |> elem(0)
    |> Kernel./(1_000)
  end

  @doc """
  Runs the given function n times and returns
  """
  def benchmark(function, opts \\ []) do
    runs = Keyword.get(opts, :runs, 30)
    warmups = Keyword.get(opts, :warmups, 2)

    # Do warmups.
    for _i <- 0..(warmups - 1) do
      function.()
    end

    # Do the actual runs.
    times =
      1..runs
      |> Enum.map(fn _ ->
        measure(function)
      end)

    # Compute the average.
    observations = Enum.count(times)
    minimum = Enum.min(times) |> round(3)
    maximum = Enum.max(times) |> round(3)
    mean = Statistics.mean(times) |> round(3)
    stddev = Statistics.standard_deviation_sample(times) |> round(3)

    cil = (mean - 1.960 * (stddev / :math.sqrt(observations))) |> round(3)
    ciu = (mean + 1.960 * (stddev / :math.sqrt(observations))) |> round(3)

    %{min: minimum, max: maximum, mean: mean, stddev: stddev, ci: {cil, ciu}}
  end

  def range(a, b, _stepsize) when a >= b, do: []

  def range(a, b, stepsize) do
    [a | range(a + stepsize, b, stepsize)]
  end
end
