import Creek.{Node, Stream, Wiring, Meta}
alias Creek.Meta.{Default, Pull, PullSlow, Squared, Logging}

dag =
  from_list([1,2,3])
  ~> map(fn x -> x + 1 end)
  ~> filter(fn x -> true end)

dag = install(dag, Logging)

sink = install(all(), Logging)

stream = run(dag, sink)

IO.inspect(get(stream))

# dag =
#   from_list([1, 2, 3])
#   ~> install(map(fn x ->
#     x
#   end), Squared)

# sink = install(all(), Default)

# stream = run(dag, sink)

# [1,4,3] == get(stream)

dag =
  from_list([1, 2, 3])
  ~> scan(0, fn x, acc -> acc + x end)

stream = run(dag, all())

result = get(stream)

IO.inspect(result)
