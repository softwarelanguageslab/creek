defmodule Parallelizer do
  use Structural

  fragment op as filter(fn event ->
                   match?({{:operator, _}, _, _}, event)
                 end)
                 ~> map(fn {{:operator, op}, dag, it} ->
                   if Keyword.has_key?(op.opts, :parallel) do
                     factor = Keyword.get(op.opts, :parallel)

                     # The output of the transform must be duplicated factor times.
                     # After the operations it must also be merged together.
                     dupper = Creek.Operator.dup(factor)
                     merger = Creek.Operator.merge(factor)
                     insert(merger)
                     insert(dupper)

                     # Swap out the map for the transform (beginning of parallel pipeline).
                     start =
                       Creek.Operator.transform(
                         0,
                         fn x, state ->
                           tag = rem(state + 1, factor)
                           {tag, {tag, x}}
                         end,
                         merger: merger.ref
                       )

                     swap!(op, start)
                     dot = GatedDag.to_dot(dag, fn x -> "#{x.name}" end)
                     File.write!("before.dot", dot)
                     # Connect the transformer to the duplicator.
                     connect(start, 0, dupper, 0)

                     dot = GatedDag.to_dot(dag, fn x -> "#{x.name}" end)
                     File.write!("after.dot", dot)

                     # Create the necessary filter and map operators.
                     # This is the actual parallel part.
                     dag =
                       0..(factor - 1)
                       |> Enum.reduce(dag, fn i, dag ->
                         f = Creek.Operator.filter(fn {tag, _v} -> tag == i end)

                         m =
                           Creek.Operator.map(fn {_tag, value} ->
                             op.arg.(value)
                           end)

                         insert(f)
                         insert(m)
                         connect(f, 0, m, 0)
                         connect(m, 0, merger, i)
                         connect(dupper, i, f, 0)
                       end)

                     dot = GatedDag.to_dot(dag, fn x -> "#{x.name}" end)
                     File.write!("pipeline.dot", dot)

                     {{:operator, start}, dag, it}
                   else
                     dot = GatedDag.to_dot(dag, fn x -> "#{x.name}" end)
                     File.write!("otherop.dot", dot)

                     {{:operator, op}, dag, it}
                   end
                 end)

  fragment edge as filter(fn event ->
                     match?({{:edge, _, _, _, _}, _, _}, event)
                   end)
                   ~> map(fn {{:edge, from, fidx, to, toidx}, dag, it} ->
                     a = fetch!(from)
                     b = fetch!(to)

                     IO.puts("#{a.name} to #{b.name}")

                     if Keyword.has_key?(a.opts, :merger) do
                       merger = Keyword.get(a.opts, :merger)
                       mergerop = fetch!(merger)
                       IO.inspect(mergerop)

                       IO.puts("#{mergerop.name} to #{b.name}")

                       {{:edge, merger, 0, to, toidx}, dag, it}
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
