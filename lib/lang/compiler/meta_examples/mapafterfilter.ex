defmodule Parallelizerr do
  use Structural

  fragment op as filter(fn event ->
                   match?({{:operator, _}, _, _}, event)
                 end)
                 ~> map(fn {{:operator, op}, dag, it} ->
                   if Keyword.has_key?(op.opts, :parallel) do
                     factor = Keyword.get(op.opts, :parallel)

                     # Add the first and last operator.
                     f1 = Creek.Operator.map(fn x -> true end)
                     f2 = Creek.Operator.filter(fn x -> true end, start: f1.ref)
                     f1 = Creek.Operator.dup(factor)
                     f2 = Creek.Operator.merge(factor, start: f1.ref)
                     insert(f1)
                     insert(f2)

                     dag =
                       Enum.reduce(0..(factor - 1), dag, fn i, dag ->
                         connect(f1, i, f2, i)
                       end)

                     {{:operator, f2}, dag, it}
                   else
                     {{:operator, op}, dag, it}
                   end
                 end)

  fragment edge as filter(fn event ->
                     match?({{:edge, _, _, _, _}, _, _}, event)
                   end)
                   ~> map(fn {{:edge, from, fidx, to, toidx}, dag, it} ->
                     a = fetch!(from)
                     b = fetch!(to)

                     if Keyword.has_key?(b.opts, :start) do
                       actual_to = Keyword.get(b.opts, :start)
                       actual_toop = fetch!(actual_to)

                       {{:edge, from, fidx, actual_toop.ref, toidx}, dag, it}
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
