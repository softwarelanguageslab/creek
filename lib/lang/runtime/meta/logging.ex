defmodule Logging do
  use Creek.MetaBehaviour

  # This DAG handles all events with default behaviour.
  fragment default as base ~> effects

  # Default behaviours.

  fragment snk_default as filter(&(not match?({_, :next, _, _}, &1)))
                          ~> default

  fragment src_default as filter(&(not match?({p, :tick}, &1)))
                          ~> default

  fragment opr_default as filter(&(not match?({_, :next, _, _}, &1)))
                          ~> default

  # Source
  fragment log_next as filter(&match?({_, :next, _, _}, &1))
                       ~> map(fn {p, :next, v, f} ->
                         IO.puts("#{p.node.name} incoming: #{inspect(v)} from #{inspect(f)}")
                         {p, :next, v, f}
                       end)
                       ~> base
                       ~> map(fn result ->
                         case result do
                           {p, {state, :next, value}} ->
                             IO.puts("#{p.node.name} outgoing: #{inspect(value)}")

                           _ ->
                             :ok
                         end

                         result
                       end)
                       ~> effects

  # Source
  fragment source_tick as filter(&match?({p, :tick}, &1))
                          ~> map(fn {p, :tick} ->
                            IO.puts("Source signaled to produce!")
                            {p, :tick}
                          end)
                          ~> base
                          ~> map(fn result ->
                            case result do
                              {p, {state, :tick, value}} ->
                                IO.puts("Source outgoing: #{inspect(value)}")

                              _ ->
                                :ok
                            end

                            result
                          end)
                          ~> effects

  defdag operator(src, snk) do
    src
    ~> dup()
    ~> (log_next ||| opr_default)
    ~> merge()
    ~> snk
  end

  defdag source(src, snk) do
    src
    ~> dup()
    ~> (source_tick ||| src_default)
    ~> merge()
    ~> snk
  end

  defdag sink(src, snk) do
    src
    ~> dup()
    ~> (log_next ||| snk_default)
    ~> merge()
    ~> snk
  end
end
