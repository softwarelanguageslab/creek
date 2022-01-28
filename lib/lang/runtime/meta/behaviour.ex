defmodule Creek.MetaBehaviour do
  defmacro __using__(_options) do
    quote do
      use Creek
      import Creek.Runtime.Process

      fragment base as map(fn event ->
                         case event do
                           {p, :tick} ->
                             {p, p.node.impl.tick(p.node, p.state)}

                           {p, :next, value, from} ->
                             {p, p.node.impl.next(p.node, p.state, p.gate, value), from}

                           {p, :complete, from} ->
                             {p, p.node.impl.complete(p.node, p.state), from}

                           {p, :init_opr} ->
                             {p, {p.state, :ok}}

                           {p, :init_src} ->
                             {p, p.node.impl.initialize(p.node, p.state)}

                           {p, :init_snk} ->
                             {p, {p.state, :ok}}

                           m ->
                             IO.puts("Meta did not understand message! #{inspect(m)}")
                         end
                       end)

      fragment effects(
                 as map(fn result ->
                      case result do
                        {p, {state, :next, value}, from} ->
                          effects_next(value, p.ds, p.pid)
                          {%{p | state: state}, :ok}

                        {p, {state, :skip}, from} ->
                          {%{p | state: state}, :ok}

                        {p, {state, :complete}, from} ->
                          effects_complete(nil, p.ds, p.us, p.pid)
                          {%{p | state: state}, :ok}

                        {p, {state, :complete}} ->
                          effects_complete(nil, p.ds, p.us, p.pid)
                          {%{p | state: state}, :ok}

                        {p, {state, :continue}, from} ->
                          us = Enum.filter(p.us, &(&1 != from))
                          effects_continue(p.ds, us, p.pid)
                          {%{p | us: us, state: state}, :ok}

                        {p, {state, :initialized}} ->
                          effects_initialize_source(p.pid)
                          {%{p | state: state}, :ok}

                        {p, {state, :ok}} ->
                          {%{p | state: state}, :ok}

                        {p, {state, :ok}, _from} ->
                          {%{p | state: state}, :ok}

                        {p, {state, :tick, value}} ->
                          effects_tick_value(p.pid, value, p.ds)
                          {%{p | state: state}, :ok}

                        m ->
                          IO.puts("Meta can not execute side effects for #{inspect(m)}!")
                      end
                    end)
               )
    end
  end
end
