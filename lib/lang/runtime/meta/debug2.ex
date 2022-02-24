defmodule Debugging2 do
  use Creek.MetaBehaviour

  dag default as base ~> effects

  ##############################################################################
  # Operators
  dag opr_outgoing as map(fn r ->
                        case r do
                          {p, {state, :next, value}, _} ->
                            {:outgoing, p.pid, state, value}

                          {p, {state, :ok}, _} ->
                            {:update, p.pid, state}

                          _ ->
                            :skip
                        end
                      end)
                      ~> filter(fn x -> x != :skip end)

  dag opr_complete as map(fn r = {p, {state, instr}, from} ->
                        if instr == :complete do
                          {:complete, p.pid}
                        else
                          :skip
                        end
                      end)

  dag incoming as map(fn {p, :next, v, from} ->
                    {:incoming, p.pid, v, p.state}
                  end)

  dag opr_done as map(fn r = {p, _} ->
                    if p.us == [] do
                      {:complete, p.pid}
                    else
                      :skip
                    end
                  end)
                  ~> filter(fn x -> x != :skip end)

  dag rest? as filter(&(not match?({_, :next, _, _}, &1)))
               ~> filter(&(not match?({_, :complete, _from}, &1)))
               ~> filter(&(not match?({_, :meta, _m, _from}, &1)))

  dag next?(as filter(&match?({_, :next, _, _}, &1)))

  dag complete?(as filter(&match?({_, :complete, from}, &1)))

  defdag operator(src, snk, sock) do
    let meta?(as filter(&match?({_, :meta, m, from}, &1)))

    # Update the argument if this is the right node.
    let metas as meta?.()
                 ~> map(fn {p, :meta, m, _from} ->
                   IO.inspect("Meta message in meta stream: #{inspect(m)}")

                   case {m, inspect(p.pid)} do
                     {{:update_arg, arg, pid}, pid} ->
                       {arg, _} = Code.eval_string(arg)
                       IO.inspect(arg, label: "new arg")
                       {%{p | node: %{p.node | arg: arg}}, :ok}

                     _ ->
                       {p, :ok}
                   end
                 end)
                 ~> snk

    # Handle next events for operators.
    let incomings as incoming
                     ~> filter(fn x -> x != :skip end)
                     ~> sock

    let outgoings as opr_outgoing
                     ~> filter(fn x -> x != :skip end)
                     ~> sock

    let do_effects as effects
                      ~> snk

    let next as next?
                ~> dup(2)
                ~> (incomings.() |||
                      base
                      ~> dup
                      ~> (outgoings.() ||| do_effects.()))

    # All unprocessed events.
    let others as rest? ~> default ~> snk

    # Handle completes.
    let complete_before_effects as opr_complete
                                   ~> filter(fn x -> x != :skip end)
                                   ~> sock

    let complete_after_effects as effects
                                  ~> dup
                                  ~> (snk ||| opr_done ~> sock)

    let completes as complete?
                     ~> base
                     ~> dup
                     ~> (opr_complete
                         ~> sock |||
                           effects
                           ~> dup()
                           ~> (snk ||| opr_done ~> sock))

    src
    ~> dup(4)
    ~> (next.() ||| others.() ||| completes.() ||| metas.())
  end

  ##############################################################################
  # Sources

  defdag source(src, snk, sock) do
    # Filters.
    let tick? as filter(&match?({_, :tick}, &1))
    let rest? as filter(&(not match?({_, :tick}, &1)))

    # All other events.
    let rests(as rest?.() ~> default() ~> snk)

    # Tick events.
    let export as map(fn e ->
                    case e do
                      {p, {state, :tick, value}} ->
                        {:outgoing, p.pid, state, value}

                      {p, {_, :complete}} ->
                        {:complete, p.pid}

                      _ ->
                        :skip
                    end
                  end)
                  ~> sock

    let ticks as tick?.()
                 ~> base()
                 ~> dup()
                 ~> (export.() ||| effects() ~> snk)

    src
    ~> dup()
    ~> (ticks.() ||| rests.())
  end

  ##############################################################################
  # Sources

  defdag sink(src, snk, sock) do
    let next? as filter(&match?({_, :next, _, _}, &1))
    let rest? as filter(&(not match?({_, :next, _, _}, &1)))
    let complete? as filter(&match?({_, :complete, _}, &1))

    let rests as rest?.() ~> default() ~> snk

    let incoming as map(fn {p, :next, v, _} ->
                      {:incoming, p.pid, v, p.state}
                    end)

    let incomings as incoming.()
                     ~> filter(fn x -> x != :skip end)
                     ~> sock

    let nexts as next?.()
                 ~> dup(2)
                 ~> (incomings.() |||
                       base
                       ~> effects
                       ~> snk)

    let export_completes as map(fn r = {p, {state, instr}, from} ->
                              if instr == :complete do
                                {:complete, p.pid}
                              else
                                :skip
                              end
                            end)
                            ~> filter(fn x -> x != :skip end)

    let completes as complete?.()
                     ~> base
                     ~> dup
                     ~> (export_completes.() ~> filter(fn x -> x != :skip end) ~> sock |||
                           effects
                           ~> snk)

    src
    ~> dup(3)
    ~> (nexts.() ||| rests.() ||| completes.())
  end
end
