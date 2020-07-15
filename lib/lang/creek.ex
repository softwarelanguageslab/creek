defmodule Creek do
  ##############################################################################
  # Macros
  defmacro __using__(_options) do
    quote do
      require unquote(__MODULE__)
      import unquote(__MODULE__)
      import Creek.CompileMeta
      import Creek.Compiler
      import Creek.Operator
      import Creek.DSL
      alias nil, as: Meta
      alias nil, as: RuntimeMeta

      def metadag(:default), do: :niks
    end
  end
end
