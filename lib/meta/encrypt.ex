defmodule Creek.Meta.Encrypt do
  require Logger
  import Creek.{Wiring, Stream, Node}

  def sink() do
    map(fn {dir, payload} ->
      case dir do
        :out ->
          nil

        :in ->
          case payload do
            {:next, {:encrypted, value}} ->
              {:next, value}

            _ ->
              nil
          end
      end
    end)
  end

  def operator() do
    map(fn {dir, payload} ->
      case dir do
        :out ->
          case payload do
            {:next, value} ->
              {:next, {:encrypted, value}}

            _ ->
              nil
          end

        :in ->
          case payload do
            {:next, {:encrypted, value}} ->
              {:next, value}

            _ ->
              nil
          end
      end
    end)
  end

  def source() do
    map(fn {dir, payload} ->
      case dir do
        :out ->
          case payload do
            {:next, value} ->
              {:next, {:encrypted, value}}

            _ ->
              nil
          end

        :in ->
          nil
      end
    end)
  end
end
