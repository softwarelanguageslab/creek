defmodule Creek.Meta.Encrypt do
  require Logger
  import Creek.{Wiring, Stream, Node}

  def sink() do
    map(fn {to, payload} ->
      Logger.error("Meta sink: #{inspect({to, payload})}")
      case payload do
        _ ->
          nil
      end
    end)
  end

  def operator() do
    map(fn {to, payload} ->
      Logger.error("Meta operator: #{inspect({to, payload})}")
      case payload do
        {:next, value} ->
          {to, {:next, {:encrypted, value}}}
        _ ->
          nil
      end
    end)
  end

  def source() do
    map(fn {to, payload} ->
      Logger.error("Meta source: #{inspect({to, payload})}")
      case payload do
        {:next, value} ->
          {to, {:next, {:encrypted, value}}}
        _ ->
          nil
      end
    end)
  end
end
