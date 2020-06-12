defmodule DSLExample do
  import Creek
  import Default

  dag =
    [list([1, 2, 3]), list([:a, :b, :c])]
    ~> zip()
    ~> map(fn x -> x end)

  stream = run(dag, list())

  result = get(stream)

  # result = [{1, :a}, {2, :b}, {3, :c}]
end

################################################################################

defmodule DSLDesugared do
  # Types:
  # map :: (a -> b) -> Operator (a -> b)
  # tolist :: [a] -> Operator [a]
  # zip :: Operator (a,b)
  #
  # dag :: DAG [Operator]
  #
  # stream :: Stream ()

  dag =
    link(
      link(
        [operator(Operator.FromList, [1, 2, 3]), operator(Operator.FromList, [1, 2, 3])],
        operator(Operator.Zip, nil)
      ),
      operator(Operator.Map, fn x -> x end)
    )

  stream = run_dag_with(dag, operator(Operator.ToList), DefaultMeta)

  result = await(stream.future)
end

################################################################################

defmodule DefaultMeta do
  import MetaStreams

  # Een meta-event op pipe niveau ziet er zo uit:
  # Event = from-node, to-node, phase, event-type, payload
  #
  # Event-dag zal gewoon alle events laten doorlopen
  # event_dag :: DAG Event -> DAG Event

  # Elke fase apart afhandelen.
  event_dag_construction =
    filter(fn event -> event.phase == :construction end)
    ~> map(fn event ->
      Logger.debug("Construction event: #{inspect(event)}")
      event
    end)
    # proceed hier praat tegen de "runtime"
    ~> proceed()
    ~> map(fn result ->
      Logger.debug("Construction event result: #{inspect(result)}")
      result
    end)

  # Een event heeft de vorm:
  # Event = from-node, to-node, phase, event-type, payload
  #
  # Een result
  # Result = (state, action)
  # action = send, skip, ...
  event_dag_data =
    filter(fn event -> event.phase == :running end)
    ~> map(fn event ->
      Logger.debug("Dataflow event: #{inspect(event)}")
      event
    end)
    # roep de base op van de node (i.e., next/error.complete/ event handlers) (proceed praat hier tegen de nodes)
    ~> proceed()
    # 1 state heeft meerdere instructies, want 1 state change kan meerdere sends doen zogezegd.
    ~> map(fn {instructions, status} ->
      {instructions, state}
    end)

  event_dag_gc = nil

  # Verwacht altijd een lijst van DAG's die moeten luisteren op de "God" stream.
  [event_dag_construction, event_dag_data, event_dag_gc]
end

################################################################################

defmodule Interpreter do
  def operator(mod, args) do
    Operator.new(mod, args)
  end

  # Hier kunnen we misschien wel operator fusion doen. Dit is in principe de compiler van de graf?
  # link :: Operator -> Operator -> DAG
  def link(op1, op2) do
    dag = Dag.new(op1)
    link(dag, op2)
  end

  # link :: DAG -> Operator -> DAG
  # link gaat er vanuit dat een DAG evenveel open outputs heeft dan dat de operator inputs heeft!
  def link(dag, op) do
    Dag.merge(dag, op)
  end
end
