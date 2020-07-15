defmodule TimestampRuntime do
  use Creek.MetaBehaviour

  # Init
  fragment init_op(
             as filter(&match?({_, :init_opr}, &1))
                ~> base()
                ~> effects()
           )

  fragment init_src as filter(&match?({_, :init_src}, &1))
                       ~> base()
                       ~> effects()

  fragment init_snk as filter(&match?({_, :init_snk}, &1))
                       ~> base()
                       ~> effects()

  # Protocol
  fragment next as filter(&match?({_, :next, _}, &1))
                   ~> base()
                   ~> effects()

  fragment complete as filter(&match?({_, :complete}, &1))
                       ~> base()
                       ~> effects()

  fragment tick as filter(&match?({_, :tick}, &1))
                   ~> base()
                   ~> effects()

  defdag operator(src, snk) do
    src
    ~> dup(3)
    ~> (init_op() ||| next() ||| complete())
    ~> merge(3)
    ~> snk
  end

  defdag source(src, snk) do
    src
    ~> dup(2)
    ~> (init_src() ||| tick())
    ~> merge(2)
    ~> snk
  end

  defdag sink(src, snk) do
    src
    ~> dup(3)
    ~> (init_snk() ||| next() ||| complete())
    ~> merge(3)
    ~> snk
  end
end
