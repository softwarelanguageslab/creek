defmodule Creek.Node.Sink.All do
  import Creek.Node.Macros
  require Creek.Node.Macros

  def complete(this, from) do
    dispose(from)
    emit_complete()
    yield(this.state)
    nil
  end

  def next(this, _from, value) do
    this.state ++ [value]
  end
end
