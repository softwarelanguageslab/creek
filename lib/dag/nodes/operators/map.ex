defmodule Creek.Node.Operator.Map do
  def next(proc, value, downstream) do
    for d <- downstream, do: send(d, {:next, proc.(value)})
  end
end
