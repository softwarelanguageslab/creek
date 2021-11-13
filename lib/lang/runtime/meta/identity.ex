defmodule IdentityMeta do
  use Creek.MetaBehaviour
  # structure(Merge)

  defdag operator(src, snk) do
    src
    ~> base()
    ~> effects()
    ~> snk
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
