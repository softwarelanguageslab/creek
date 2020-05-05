import Creek.{Node, Stream, Wiring, Meta}
alias Creek.Meta.Default

dag = single(0) ~> map(fn x -> x + 1 end)

dag = install(dag, Default)

sink = install(all(), Default)

stream = run(dag, all())

IO.inspect get(stream)
