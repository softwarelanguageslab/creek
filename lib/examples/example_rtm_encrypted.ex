defmodule Creek.ExampleRtmE do
  @moduledoc """
  An example of encryption at runtime.

  We assume that the values arrive encrypted, and the runtime will decrypt the value for each application of each operator, and encrypt it when the result has been computed.
  """
  use Creek
  execution(Encrypted)

  # Bench with
  fragment mapper as map(fn x -> x end)
                     ~> map(fn x -> x end)

  defdag test(src, snk) do
    src ~> mapper() ~> snk
  end

  @spec main :: any
  def main() do
    source = Creek.Source.list([1, 2, 3, 4] |> Enum.map(&{:encrypted, &1}))

    ivar = Ivar.new()
    sink = Creek.Sink.all(ivar)

    Creek.Runtime.run(test(), [src: source, snk: sink], dot: true)

    ivar
    |> Ivar.get()
    |> IO.inspect()
  end
end
