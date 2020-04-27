defmodule Creek.Node.Sink.FanOut do
  import Creek.Node.Macros
  require Creek.Node.Macros

  def complete(_this, _from) do
    emit_complete()
    nil
  end

  def next(_this, _from, value) do
    emit_value(value)
    nil
  end
end
