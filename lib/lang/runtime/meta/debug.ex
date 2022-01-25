defmodule Debugging do
  use Creek.MetaBehaviour

  fragment default as base ~> effects

  fragment opr_next as filter(&match?({_, :next, _, _}, &1))
                       ~> map(fn {p, :next, v, from} ->
                        #  IO.inspect {p, :next, v, from}, label: "meta event"

                        Phoenix.PubSub.broadcast(Creek.PubSub, "incoming", {:incoming, p.pid, v})
                         {p, :next, v, from}
                       end)
                       ~> base()
                       ~> effects()

  fragment opr_default as filter(&(not match?({_, :next, _, _}, &1)))
                          ~> default

  defdag operator(src, snk) do
    src
    ~> dup(2)
    ~> (opr_next ||| opr_default)
    ~> merge(2)
    ~> snk
  end

  defdag source(src, snk) do
    src
    ~> default
    ~> snk
  end

  defdag sink(src, snk) do
    src
    ~> default
    ~> snk
  end
end
