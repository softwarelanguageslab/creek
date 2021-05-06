defmodule Creek.NoSink do
  use Creek
  # meta(Merge)
  # runtime_meta(Creek.Runtime.Meta.Default)

  defdag test(src) do
    src
    ~> map(fn x -> IO.puts(x) end)
  end

  @spec main :: any
  def main() do
    source = Creek.Source.range(0, :infinity)
    Creek.Runtime.run(test(), [src: source], dot: true)
  end
end
