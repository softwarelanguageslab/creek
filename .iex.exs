import Creek.{Node, Stream, Wiring}

dag = single(0)
stream = run(dag, fanout())

left = extend(stream, map(fn x -> x end), head())

IO.puts(get(left))
