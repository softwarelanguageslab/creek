defmodule Creek.ExampleRtm do
  @moduledoc """
  An example of using the default meta-level. That is to say, each value will be propagated through the meta-level, but the meta-level will not actually do anything.
  """
  use Creek
  execution(IdentityMeta)

  fragment mapper as map(fn x -> x end)
                     ~> map(fn x -> x end)

  defdag test(src, snk) do
    src ~> mapper() ~> snk
  end

  @spec main :: any
  def main() do
    source = Creek.Source.list([1, 2, 3, 4])

    ivar = Ivar.new()
    sink = Creek.Sink.all(ivar)

    Creek.Runtime.run(test(), [src: source, snk: sink], dot: true)

    ivar
    |> Ivar.get()
    |> IO.inspect()
  end
end
