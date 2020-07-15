defmodule Timestamp do
  use Structural

  # +-+   +-+
  # |A|   |A|
  # +++   +-+
  #  v     v
  # +++   +-+
  # |B|   |T|
  # +-+   +-+
  #        v
  #       +-+
  #       |B|
  #       +-+

  fragment operator as filter(fn event ->
                         match?({{:operator, _}, _, _}, event)
                       end)
                       ~> map(fn {{:operator, op}, dag, it} ->
                         new_op =
                           case op.arg do
                             f when is_function(f) ->
                               %{op | arg: fn {:timestamped, x} -> {:timestamped, f.(x)} end}

                             _ ->
                               op
                           end

                         {{:operator, new_op}, dag, it}
                       end)

  fragment edge as filter(fn event ->
                     match?({{:edge, _, _, _, _}, _, _}, event)
                   end)
                   ~> map(fn {{:edge, from, fidx, to, toidx}, dag, it} ->
                     a = fetch!(from)
                     b = fetch!(to)

                     ts =
                       map(fn x ->
                         case x do
                           {:timestamped, x} ->
                             {:timestamped, x}

                           _ ->
                             {:timestamped, x}
                         end
                       end)

                     insert(ts)
                     connect(a, fidx, ts, 0)

                     {{:edge, ts.ref, 0, b.ref, toidx}, dag, it}
                   end)

  defdag metadag(src, snk) do
    src
    ~> dup(3)
    ~> (edge() ||| operator() ||| default_name())
    ~> merge(3)
    ~> proceed()
    ~> snk
  end
end
