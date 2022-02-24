defmodule SmartPull do
  use Creek.MetaBehaviour

  # This DAG handles all events with default behaviour.
  fragment default as base ~> effects

  ##############################################################################
  # Operators

  # This DAG propagates every demand message upstream.

  fragment forward_demand as filter(&match?({_, :meta, :demand, from}, &1))
                             ~> map(fn {p, :meta, :demand, from} ->
                               # Demand as operator means it needs to be propagated.
                               # Only propagate to the operators which are not marked
                               # as "demanded".
                               demanded = p.meta_state
                               to_demand = p.us |> Enum.filter(&(not MapSet.member?(demanded, &1)))
                               propagate_upstream_meta(:demand, to_demand, p.pid)
                               meta_state = MapSet.new(p.us)
                               {%{p | meta_state: meta_state}, :ok}
                             end)

  # If an operator does not propagate a vlaue the demand is "lost".
  # As soon as no value is propagated in response, a new demand is sent.
  fragment opr_next as filter(&match?({_, :next, _, _}, &1))
                       ~> map(fn {p, :next, v, from} ->
                         meta_state = p.meta_state |> MapSet.delete(from)
                         {%{p | meta_state: meta_state}, :next, v, from}
                       end)
                       ~> base()
                       ~> map(fn {p, base_response, from} ->
                         if match?({_, :skip}, base_response) do
                           demanded = p.meta_state
                           to_demand = p.us |> Enum.filter(&(not MapSet.member?(demanded, &1)))
                           propagate_upstream_meta(:demand, to_demand, p.pid)
                         end

                         {p, base_response, from}
                       end)
                       ~> effects()

  fragment opr_default as filter(&(not match?({_, :meta, :demand, _}, &1)))
                          ~> filter(&(not match?({_, :next, _, _}, &1)))
                          ~> filter(&(not match?({_, :init_opr}, &1)))
                          ~> default

  fragment init_opr as filter(&match?({_, :init_opr}, &1))
                       ~> base()
                       ~> map(fn {p, resp} ->
                         p = %{p | meta_state: MapSet.new()}
                         {p, resp}
                       end)
                       ~> effects()

  defdag operator(src, snk) do
    src
    ~> dup(4)
    ~> (opr_default ||| forward_demand ||| opr_next ||| init_opr)
    ~> merge(4)
    ~> snk
  end

  ##############################################################################
  # Sources
  # Intercept the init event for sources to stop them from ticking themselves.
  fragment init_src as filter(&match?({_, :init_src}, &1))
                       ~> base()
                       ~> map(fn {p, {state, :initialized}} ->
                         # Here we would normally send tick to ourselves, but we dont (pull).
                         {%{p | state: state}, :ok}
                       end)

  # This DAG handles the demand messages.
  fragment demand_src as filter(&match?({p, :meta, :demand, _}, &1))
                         ~> map(fn {p, :meta, :demand, _} ->
                           # If a source receives demand it ticks itself.
                           send_self({:tick}, p.pid)
                           {p, :ok}
                         end)

  # If a source gets a tick event (from itself) it will produce a value and tick itself again.
  # We intercept that tick and stop from sending it.
  fragment tick_src as filter(&match?({p, :tick}, &1))
                       ~> base()
                       ~> map(fn base_result ->
                         case base_result do
                           {p, {state, :complete}} ->
                             effects_complete(nil, p.ds, p.us, p.pid)
                             {%{p | state: state}, :ok}

                           {p, {state, :tick, value}} ->
                             propagate_downstream({:next, value}, p.ds, p.pid)
                             {%{p | state: state}, :ok}
                         end
                       end)

  # This DAG handles all events except the ones we intercepted.
  fragment src_default as filter(&(not match?({_, :init_src}, &1)))
                          ~> filter(&(not match?({_, :meta, _, _}, &1)))
                          ~> filter(&(not match?({p, :tick}, &1)))
                          ~> default

  defdag source(src, snk) do
    src
    ~> dup(4)
    ~> (src_default ||| init_src ||| demand_src ||| tick_src)
    ~> merge(4)
    ~> snk
  end

  ##############################################################################
  # Sinks

  # When a sink is initialized it normally doesnt do anything.
  # In pull-based we must send the first pull message.
  fragment init_snk as filter(&match?({_, :init_snk}, &1))
                       ~> base()
                       ~> map(fn {p, {_, :ok}} ->
                         # Normally no side-effects happen in a sink init, but now e must propagate demand upstream.
                         propagate_upstream_meta(:demand, p.us, p.pid)
                         {p, :ok}
                       end)

  # This DAG ensures that a new demand is sent when a next value arrived.
  fragment next_snk as filter(&match?({_, :next, _, _}, &1))
                       ~> default()
                       ~> map(fn {p, :ok} ->
                         # After the default, we send demand upstream.
                         propagate_upstream_meta(:demand, p.us, p.pid)
                         {p, :ok}
                       end)

  # This DAG handles all events except the ones we intercepted.
  fragment snk_default as filter(&(not match?({_, :init_snk}, &1)))
                          ~> filter(&(not match?({_, :next, _, _}, &1)))
                          ~> default()

  defdag sink(src, snk) do
    src
    ~> dup(3)
    ~> (init_snk ||| snk_default ||| next_snk)
    ~> merge(3)
    ~> snk
  end
end
