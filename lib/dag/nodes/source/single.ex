defmodule Creek.Node.Source.Single do
  import Creek.Node.Macros
  require Creek.Node.Macros

  def subscribe(this) do
    Process.sleep(100)
    emit_value(this.argument)
    emit_complete()
  end
end
