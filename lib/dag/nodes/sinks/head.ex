defmodule Creek.Node.Sink.Head do
  import Creek.Node.Macros
  require Creek.Node.Macros

  def complete(_this, from) do
    dispose(from)
    yield(nil)
    nil
  end

  def next(_this, from, value) do
    dispose(from)
    yield(value)
    nil
  end
end
