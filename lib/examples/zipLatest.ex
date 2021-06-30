defmodule Creek.ZipLatest do
  @moduledoc """
  An example of using the default meta-level. That is to say, each value will be propagated through the meta-level, but the meta-level will not actually do anything.
  """
  use Creek
  execution(Pull)

  defdag test(src1, src2, snk) do
    (src1 ||| src2) ~> zipLatest() ~> snk
  end

  @spec main :: any
  def main() do
    s1 = Creek.Source.range(0, 5)
    s2 = Creek.Source.range(10, 20)

    ivar = Ivar.new()
    sink = Creek.Sink.all(ivar)

    Creek.Runtime.run(test(), [src1: s1, src2: s2, snk: sink], dot: true)

    ivar
    |> Ivar.get()
  end

  def testall() do
    IO.puts("Creek.BalanceExample.main()")
    Creek.BalanceExample.main()
    IO.puts("Creek.ExampleCtmRtm.main()")
    Creek.ExampleCtmRtm.main()
    IO.puts("Creek.ExampleCtm.main()")
    Creek.ExampleCtm.main()
    IO.puts("Creek.ExampleCtmTs.main()")
    Creek.ExampleCtmTs.main()
    IO.puts("Creek.ExampleRtmE.main()")
    Creek.ExampleRtmE.main()
    IO.puts("Creek.ExampleRtmPull.main()")
    Creek.ExampleRtmPull.main()
    IO.puts("Creek.ExampleRtm.main()")
    Creek.ExampleRtm.main()
    IO.puts("Creek.ExampleRtmLogging.main()")
    Creek.ExampleRtmLogging.main()
    IO.puts("Creek.ExampleCtmPar.main()")
    Creek.ExampleCtmPar.main()
  end
end
