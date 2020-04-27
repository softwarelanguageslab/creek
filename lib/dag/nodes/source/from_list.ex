defmodule Creek.Node.Source.FromList do
  import Creek.Node.Macros
  require Creek.Node.Macros

  def subscribe(this) do
    # for testing purposes
    Process.sleep(500)

    for value <- this.argument do
      emit_value(value)
    end

    emit_complete()
  end
end
