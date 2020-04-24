import Creek.{Node, Stream, Wiring}

dag = single(0) ~> map(fn x -> x + 1 end)

dag = Creek.Meta.install(dag, Creek.Meta.Encrypt)
sink = Creek.Meta.install(all(), Creek.Meta.Encrypt)

stream = run(dag, sink)

result = get(stream)

IO.puts "Result: #{inspect result}"
