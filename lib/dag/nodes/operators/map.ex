defmodule Creek.Node.Operator.Map do
  import Creek.Node.Macros
  require Creek.Node.Macros

  def next(this, _from, value) do
    func = this.argument
    new_value = func.(value)
    emit_value(new_value)
  end

  def complete(this, from) do
    if Enum.count(this.upstream) == 1, do: emit_complete()
    dispose(from)
  end
end
