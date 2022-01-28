require Logger

output = System.get_env("CSV")
{nodes, ""} = System.get_env("NODES") |> Integer.parse()
{values, ""} = System.get_env("VALS") |> Integer.parse()

prog = fn ->
  Creek.BenchmarkApp.main()
end

results = Benchmark.benchmark(prog)

resultline = "#{nodes},#{values},#{results[:max]},#{results[:min]},#{results[:mean]},#{results[:stddev]},#{results[:ci] |> elem(0)},#{results[:ci] |> elem(1)}"

IO.puts(resultline)
res = File.write!(output, resultline <> "\n", [:append])
