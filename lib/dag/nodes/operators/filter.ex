defmodule Creek.Node.Operator.Filter do
  import Creek.Node.Macros
  require Creek.Node.Macros

  def next(this, _from, value) do
    func = this.argument

    if func.(value) do
      emit_value(value)
    end
  end

  def complete(this, from) do
    if Enum.count(this.upstream) == 1, do: emit_complete()
    dispose(from)
  end
end
