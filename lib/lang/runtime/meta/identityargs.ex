defmodule IdentityMetaArg do
  use Creek.MetaBehaviour
  # structure(Merge)

  defdag operator(src, snk, tap) do
    src
    ~> base()
    ~> effects()
    ~> dup(2)
    ~> (snk ||| tap)
  end

  defdag source(src, snk) do
    src
    ~> base()
    ~> effects()
    ~> snk
  end

  defdag sink(src, snk) do
    src
    ~> base()
    ~> effects()
    ~> snk
  end
end
