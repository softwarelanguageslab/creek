defmodule CreekTest.Program do
  use Creek

  defdag test(src, snk) do
    src ~> snk
  end

  def main() do
    source = Creek.Source.range(0, 1000, 100)
    ivar = Ivar.new()
    sink = Creek.Sink.all(ivar)
    Creek.Runtime.run(test(), [src: source, snk: sink], dot: true)

    ivar
    |> Ivar.get()
  end
end

defmodule CreekTest do
  use ExUnit.Case
  doctest Creek

  test "Range operator" do
    assert [0, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000] == CreekTest.Program.main()
  end
end
