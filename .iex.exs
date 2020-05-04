import Creek.{Node, Stream, Wiring, Meta}
alias Creek.Meta.Encrypt

dag = single(0) ~> map(fn x -> x + 1 end)

dag = install(dag, Encrypt)

sink = install(all(), Encrypt)

stream = run(dag, all())
