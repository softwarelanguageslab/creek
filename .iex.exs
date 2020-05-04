import Creek.{Node, Stream, Wiring}

dag = single(0) ~> map(fn x -> x + 1 end)

stream = run(dag, all())
