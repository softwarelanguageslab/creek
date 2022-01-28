defmodule Proxy do
  use Creek

  defdag proxy(src, snk) do
    src
    ~> snk
  end
end
