defmodule Debugging do
  use Creek.MetaBehaviour

  fragment default as base ~> effects

  fragment opr_next as filter(&match?({_, :next, _, _}, &1))
                       ~> map(fn {p, :next, v, from} ->
                         Phoenix.PubSub.broadcast(Creek.PubSub, "incoming", {:incoming, p.pid, v, p.state})
                         {p, :next, v, from}
                       end)
                       ~> base()
                       ~> map(fn r ->
                         case r do
                           {p, {state, :next, value}, from} ->
                             Phoenix.PubSub.broadcast(Creek.PubSub, "outgoing", {:outgoing, p.pid, state, value})

                           {p, {state, :ok}, from} ->
                             Phoenix.PubSub.broadcast(Creek.PubSub, "outgoing", {:update, p.pid, state})

                           _ ->
                             IO.puts("Message did not match..")
                             IO.inspect(r, pretty: true)
                         end

                         r
                       end)
                       ~> effects()

  fragment opr_complete(
             as filter(&match?({_, :complete, from}, &1))
                ~> map(fn {p, :complete, from} ->
                  if p.node.impl == Creek.Operator.Transform do
                    IO.puts("Transform got a complete")
                  end

                  # Phoenix.PubSub.broadcast(Creek.PubSub, "complete", {:complete, p.pid})
                  {p, :complete, from}
                end)
                ~> base()
                ~> map(fn r = {p, {state, instr}, from} ->
                  if p.node.impl == Creek.Operator.Transform do
                    IO.puts("2 Transform got a complete")
                    IO.inspect(instr)
                  end

                  if instr == :complete do
                    IO.puts("Sending complete")
                    Phoenix.PubSub.broadcast(Creek.PubSub, "complete", {:complete, p.pid})
                  end

                  IO.puts("end")
                  r
                end)
                ~> effects()
                ~> map(fn r = {p, _} ->
                  if p.node.impl == Creek.Operator.Transform do
                    IO.puts("Transform got a complete")
                  end

                  # Phoenix.PubSub.broadcast(Creek.PubSub, "complete", {:complete, p.pid})
                  r
                end)
                ~> map(fn r = {p, _} ->
                  if p.us == [] do
                    Phoenix.PubSub.broadcast(Creek.PubSub, "complete", {:complete, p.pid})
                  end

                  r
                end)
           )

  fragment opr_default as filter(&(not match?({_, :next, _, _}, &1)))
                          ~> filter(&(not match?({_, :complete, _from}, &1)))
                          ~> default

  fragment source_tick as filter(&match?({p, :tick}, &1))
                          ~> map(fn {p, :tick} ->
                            {p, :tick}
                          end)
                          ~> base
                          ~> map(fn result ->
                            case result do
                              {p, {state, :tick, value}} ->
                                Phoenix.PubSub.broadcast(Creek.PubSub, "outgoing", {:outgoing, p.pid, state, value})

                              {p, {state, :complete}} ->
                                Phoenix.PubSub.broadcast(Creek.PubSub, "complete", {:complete, p.pid})

                              _ ->
                                IO.inspect(result)
                                :ok
                            end

                            result
                          end)
                          ~> effects

  fragment src_default as filter(&(not match?({p, :tick}, &1)))
                          ~> map(fn evt ->
                            evt
                          end)
                          ~> default

  fragment snk_default as filter(&(not match?({_, :next, _, _}, &1)))
                          ~> default

  defdag operator(srco, snko) do
    srco
    ~> dup(3)
    ~> (opr_next ||| opr_default ||| opr_complete)
    ~> merge(3)
    ~> snko
  end

  defdag source(srcsrc, snksrc) do
    srcsrc
    ~> dup()
    ~> (source_tick ||| src_default)
    ~> merge()
    ~> snksrc
  end

  defdag sink(srcs, snks) do
    srcs
    ~> dup(3)
    ~> (opr_next ||| opr_default ||| opr_complete)
    ~> merge(3)
    ~> snks
  end
end
