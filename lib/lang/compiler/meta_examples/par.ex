defmodule Parallelize do
  use Structural

  fragment op as filter(fn event ->
                   match?({{:operator, _}, _, _}, event)
                 end)
                 ~> map(fn {{:operator, op}, dag, it} ->
                   if Keyword.has_key?(op.opts, :parallel) do
                     factor = Keyword.get(op.opts, :parallel)

                     # Create and insert the duplicate and merge operators (start and end of parallel part).
                     endng = Creek.Operator.merge(factor)

                     start =
                       Creek.Operator.transform(
                         0,
                         fn x, state ->
                           tag = rem(state + 1, factor)
                           {tag, {tag, x}}
                         end,
                         ending: endng.ref
                       )

                     dupper = Creek.Operator.dup(factor)
                     swap!(op, start)
                     insert(endng)
                     insert(dupper)
                     connect(start, 0, dupper, 0)

                     dag =
                       0..(factor - 1)
                       |> Enum.reduce(dag, fn i, dag ->
                         f = Creek.Operator.filter(fn {tag, _v} -> tag == i end)

                         m =
                           Creek.Operator.map(fn {tag, value} ->
                             op.arg.(value)
                           end)

                         insert(f)
                         insert(m)
                         connect(f, 0, m, 0)
                         connect(m, 0, endng, i)
                         connect(dupper, i, f, 0)
                       end)

                     {{:operator, start}, dag, it}
                   else
                     {{:operator, op}, dag, it}
                   end
                 end)

  fragment edge as filter(fn event ->
                     match?({{:edge, _, _, _, _}, _, _}, event)
                   end)
                   ~> map(fn {{:edge, from, fidx, to, toidx}, dag, it} ->
                     a = fetch!(from)

                     if Keyword.has_key?(a.opts, :ending) do
                       {{:edge, Keyword.get(a.opts, :ending), fidx, to, toidx}, dag, it}
                     else
                       {{:edge, from, fidx, to, toidx}, dag, it}
                     end
                   end)

  defdag metadag(src, snk) do
    src
    # ~> map(fn {ev, dag, it} ->
    #   IO.inspect(ev, label: "event")
    #   {ev, dag, it}
    # end)
    ~> dup(3)
    ~> (op ||| edge ||| default_name)
    ~> merge(3)
    ~> proceed()
    ~> snk
  end
end

#  IO.inspect(balance, label: "balance")
#  IO.inspect(op, label: "op")
#  swap!(op, balance)
#  merge = Creek.Operator.merge(factor)
#  insert(merge)
#  IO.inspect(merge, label: "merge")
#  # Create the operators.
#  operators = 1..factor |> Enum.map(fn _ -> Creek.Operator.map(op.arg) end)
#  IO.inspect(operators, label: "operators")

#  # Add the operators to the DAG.
#  dag =
#    operators
#    |> Enum.zip(0..(factor - 1))
#    |> Enum.reduce(dag, fn {op, i}, dag ->
#      insert(op)
#      connect(balance, i, op, 0)
#      connect(op, 0, merge, i)
#    end)
