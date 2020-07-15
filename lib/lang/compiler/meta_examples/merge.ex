defmodule Merge do
  use Structural

  # To replace an operator
  # +---+      +---+      +---+
  # | X |      | X |      | X |
  # +-+-+      +-+-+      +-+-+
  #   |          |          |
  #   v          v          |
  # +-+-+      +-+-+        |
  # | A |      | A |        |
  # +-+-+      +-+-+        |
  #   |          |          |
  #   v          v          |
  # +-+-+      +-+-+        |
  # | B |      | B |        |
  # +---+      +---+        |
  #                         |
  #                         v
  #            +---+      +-+-+
  #            | C |      | C |
  #            +---+      +---+

  #    fuse(a, b)         delete(a) ; swap(b, c)

  fragment edge as filter(fn event ->
                     match?({{:edge, _, _, _, _}, _, _}, event)
                   end)
                   ~> map(fn {{:edge, from, fidx, to, toidx}, dag, it} ->
                     a = fetch!(from)
                     b = fetch!(to)

                     case {a.name, b.name} do
                       {"map", "filter"} ->
                         [x] = inputs(a)

                         c = fuse(a, b)
                         delete(a)
                         swap!(b, c)

                         {{:edge, x.ref, 0, c.ref, 0}, dag, it}

                       {"filter", "filter"} ->
                         [x] = inputs(a)

                         c =
                           fuse(a, b, fn f, g ->
                             fn value ->
                               f.(value) and g.(value)
                             end
                           end)

                         delete(a)
                         swap!(b, c)
                         {{:edge, x.ref, 0, c.ref, 0}, dag, it}

                       {"map", "map"} ->
                         [x] = inputs(a)

                         c = fuse(a, b)
                         delete(a)
                         swap!(b, c)

                         {{:edge, x.ref, 0, c.ref, 0}, dag, it}

                       _ ->
                         {{:edge, from, fidx, to, toidx}, dag, it}
                     end
                   end)

  defdag metadag(src, snk) do
    src
    ~> dup(3)
    ~> (edge() ||| default_operator() ||| default_name())
    ~> merge(3)
    ~> proceed()
    ~> snk
  end
end
