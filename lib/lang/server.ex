defmodule Creek.Server do
  @moduledoc """
  A GenServer process which is used to generate easily readable names.
  Should be useful for future stuff as well which requires state.
  """
  use GenServer
  require Logger
  alias __MODULE__

  defstruct count: 0, id: 0, compiled: %{}, streams: %{}, operators: %{}

  def start_link([]) do
    GenServer.start_link(__MODULE__, %Server{}, name: __MODULE__)
  end

  def init(opts) do
    # Phoenix.PubSub.subscribe(Creek.PubSub, @topic)
    {:ok, opts}
  end

  #######
  # API #
  #######

  def gen_sym() do
    GenServer.call(__MODULE__, :gen_sym)
  end

  def gen_id() do
    GenServer.call(__MODULE__, :gen_id)
  end

  def store_compiled(name, dag) do
    GenServer.call(__MODULE__, {:store, dag, name})
  end

  def fetch(name) do
    GenServer.call(__MODULE__, {:fetch, name})
  end

  def clear_cache() do
    GenServer.call(__MODULE__, :clear_cache)
  end

  def add_stream(id, stream) do
    GenServer.call(__MODULE__, {:add_stream, id, stream})
  end

  def get_streams() do
    GenServer.call(__MODULE__, :all_streams)
  end

  def add_operator(id, operator) do
    GenServer.call(__MODULE__, {:add_operator, id, operator})
  end

  #############
  # Callbacks #
  #############

  def handle_call({:add_operator, id, operator}, _from, state) do
    {:reply, :ok, %{state | operators: Map.put(state.operators, id, operator)}}
  end

  def handle_call({:add_stream, id, stream}, _from, state) do
    stream =
      stream
      |> Enum.map(fn {from, fidx, to, tidx} ->
        %{from: from, fidx: fidx, to: to, tidx: tidx}
      end)

    Phoenix.PubSub.broadcast(Creek.PubSub, "streams:new", {:new_stream, id, stream})
    {:reply, :ok, %{state | streams: Map.put(state.streams, id, stream)}}
  end

  def handle_call(:all_streams, _from, state) do
    {:reply, state.streams, state}
  end

  def handle_call(:clear_cache, _from, state) do
    {:reply, :ok, %{state | compiled: Map.new()}}
  end

  def handle_call({:store, dag, name}, _from, state) do
    {:reply, :ok, %{state | compiled: Map.put(state.compiled, name, dag)}}
  end

  def handle_call({:fetch, name}, _from, state) do
    {:reply, Map.get(state.compiled, name, nil), state}
  end

  def handle_call(:gen_sym, _from, state) do
    {:reply, "var#{state.count}", %{state | count: state.count + 1}}
  end

  def handle_call(:gen_id, _from, state) do
    {:reply, "uuid#{state.id}", %{state | id: state.id + 1}}
  end

  def handle_call(m, from, state) do
    Logger.debug("Call #{inspect(m)} from #{inspect(from)} with state #{inspect(state)}")
    {:reply, :response, state}
  end

  def handle_info(value, state) do
    # IO.inspect(value, label: "info at server")
    {:noreply, state}
  end

  ###########
  # Helpers #
  ###########
end
