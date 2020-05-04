defmodule Creek.Meta.Encrypt do
  require Logger
  import Creek.{Node}

  def sink() do

  end

  def operator() do

  end

  def source() do
    map(fn meta_event ->
      case meta_event.event do
        :subscribe ->
          this = %{}
          {state, response} = meta_event.node.subscribe.(this, meta_event.state, meta_event.from)

          case response do
            :continue ->
              send(meta_event.base, :tick)
              :ok

            _ ->
              Logger.error("Source callback subscribe/3 produced invalid returnvalue: #{inspect(response)}")
          end

          # Return response to base-level.
          state
      end
    end)
  end
end
