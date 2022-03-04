defmodule Creek.CompileMeta do
  require Logger
  ##############################################################################
  # Stream Events
  def stream_events_to_dag(_eventlist, nil) do
    nil
  end

  def stream_events_to_dag(eventlist, [meta_module | meta_modules]) do
    # Build the stream through which the values need to be pushed.
    source = Creek.Source.subject(description: "compiletime subject")
    sink = Creek.Sink.tap(self())
    Creek.Runtime.run(meta_module.metadag, src: source, snk: sink)

    {dag, _} =
      eventlist
      |> Enum.reduce({GatedDag.new(), nil}, fn event, {dag, it} ->
        # {dag, it} = push_value_through_stream({event, dag, it}, meta_module.metadag)
        # {dag, it}
        send(source, {:next, {event, dag, it}})

        receive do
          v ->
            v
        end
      end)

    send(source, {:complete})

    dag
  end

  def stream_events_to_dag(eventlist, meta_module) do
    # Build the stream through which the values need to be pushed.
    source = Creek.Source.subject(description: "Compiletime subject")
    sink = Creek.Sink.tap(self())
    Creek.Runtime.run(meta_module.metadag, src: source, snk: sink)

    {dag, _} =
      eventlist
      |> Enum.reduce({GatedDag.new(), nil}, fn event, {dag, it} ->
        # {dag, it} = push_value_through_stream({event, dag, it}, meta_module.metadag)
        # {dag, it}
        send(source, {:next, {event, dag, it}})

        receive do
          v ->
            v
        end
      end)

    send(source, {:complete})

    dag
  end

  @spec push_value_through_stream(any, GatedDag.t()) :: any
  def push_value_through_stream(event, the_dag) do
    ivar = Ivar.new()
    source = Creek.Source.single(event)
    sink = Creek.Sink.first(ivar)
    Creek.Runtime.run(the_dag, src: source, snk: sink)
    Ivar.get(ivar)
  end
end
