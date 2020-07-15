defmodule Statistics do
  import Enum

  def mean(xs) do
    sum(xs) / count(xs)
  end

  def standard_deviation_sample(observations) do
    mean = mean(observations)
    :math.sqrt(sum(map(observations, fn x -> :math.pow(x - mean, 2) end)) / (count(observations) - 1))
  end

  def confidence_interval(xs, ci) do
    z =
      case ci do
        95 -> 1.960
        99.9 -> 3.291
        _ -> throw("Invalid CI given.")
      end

    mean = mean(xs)
    stddev = standard_deviation_sample(xs)
    observations = count(xs)
    cil = mean - z * (stddev / :math.sqrt(observations))
    ciu = mean + z * (stddev / :math.sqrt(observations))

    {cil, ciu}
  end
end
