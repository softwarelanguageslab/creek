defmodule Creek.Node.Operator.Flatten do
  import Creek.Node.Macros
  require Creek.Node.Macros

  import Creek.Stream

  def next(this, value) do
    [downstream] = this.downstream

    # Realize the value and direct its values to our downstream.
    value
    |> run(downstream)
  end

  def complete(this, from) do
    # If we only have one more upstream we can safely complete.
    if MapSet.size(this.upstream) == 1, do: emit_complete()

    # Dispose the upstream, as it's done.
    dispose(from)
  end
end
