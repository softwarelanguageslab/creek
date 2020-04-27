defmodule Creek.Node.Sink.FanOut do
  import Creek.Node.Macros
  require Creek.Node.Macros

  def complete(_this, _from) do
    nil
  end

  def next(_this, value) do
    emit_value(value)
    nil
  end
end
