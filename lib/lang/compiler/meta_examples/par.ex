defmodule Parallelize do
  use Structural

  fragment op as filter(fn event ->
                   match?({{:operator, _}, _, _}, event)
                 end)
                 ~> map(fn {{:operator, op}, dag, it} ->
                   if Keyword.has_key?(op.opts, :parallel) do
                     factor = Keyword.get(op.opts, :parallel)

                     #    +---+
                     #    |dup|
                     #    +---+
                     #    v   v
                     # +--++ ++--+
                     # |map| |map|
                     # +---+ +---+
                     #     v v
                     #    ++-++
                     #    |mrg|
                     #    +---+
                     # The output of the transform must be duplicated factor times.
                     # After the operations it must also be merged together.

                     # The transform operator will tag each value with an index.
                     # This is used to balance them across the parallel pipelines.
                     f1 =
                       Creek.Operator.transform(
                         0,
                         fn x, state ->
                           tag = rem(state + 1, factor)
                           {tag, {tag, x}}
                         end
                       )

                     insert(f1)

                     # The parallel pieplines need to be merged together in the end.
                     f_n = Creek.Operator.merge(factor, start: f1.ref)
                     insert(f_n)

                     # The transformed tagged values need to duplicated across
                     # each pipeline using duplicate.
                     f2 = Creek.Operator.dup(factor)
                     insert(f2)

                     # Transform emits to duplicate directly.
                     connect(f1, 0, f2, 0)

                     dag =
                       0..(factor - 1)
                       |> Enum.reduce(dag, fn i, dag ->
                         f =
                           Creek.Operator.filter(fn {tag, v} ->
                             tag == i
                           end)

                         m =
                           Creek.Operator.map(fn {_tag, value} ->
                             Process.sleep(i * 1000)
                             op.arg.(value)
                           end)

                         insert(f)
                         insert(m)
                         # Connect map after filter.
                         connect(f, 0, m, 0)
                         # Each map outputs to the merge.
                         connect(m, 0, f_n, i)
                         # Each filter is connected to the duplicator.
                         connect(f2, i, f, 0)
                         dag
                       end)

                     {{:operator, f_n}, dag, it}
                   else
                     {{:operator, op}, dag, it}
                   end
                 end)

  fragment edge as filter(fn event ->
                     match?({{:edge, _, _, _, _}, _, _}, event)
                   end)
                   ~> map(fn {{:edge, from, fidx, to, toidx}, dag, it} ->
                     b = fetch!(to)

                     if Keyword.has_key?(b.opts, :start) do
                       actual_to = Keyword.get(b.opts, :start)
                       {{:edge, from, fidx, actual_to, toidx}, dag, it}
                     else
                       {{:edge, from, fidx, to, toidx}, dag, it}
                     end
                   end)

  defdag metadag(src, snk) do
    src
    ~> dup(3)
    ~> (op ||| edge ||| default_name)
    ~> merge(3)
    ~> proceed()
    ~> snk
  end
end
