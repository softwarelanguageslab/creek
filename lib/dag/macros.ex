defmodule Creek.Node.Macros do
  defmacro emit_value(value) do
    quote do
      send(self(), {:emit_value, unquote(value)})
    end
  end

  defmacro emit_complete() do
    quote do
      send(self(), {:emit_complete})
    end
  end

  defmacro dispose(who) do
    quote do
      send(self(), {:emit_dispose_upstream, unquote(who)})
    end
  end

  defmacro yield(value) do
    quote do
      send(self(), {:yield, unquote(value)})
    end
  end
end
