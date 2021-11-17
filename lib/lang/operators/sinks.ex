defmodule Creek.Sink do
  alias Creek.Operator

  def all(ivar) do
    o = %Operator{type: :sink, arg: {ivar, []}, name: "all", ref: Creek.Server.gen_sym(), in: 1, out: 0, impl: Creek.Sink.All}

    spawn(fn ->
      Creek.Runtime.Process.sink(o, [])
    end)
  end
  def ignore() do
    o = %Operator{type: :sink, arg: nil, name: "ignore", ref: Creek.Server.gen_sym(), in: 1, out: 0, impl: Creek.Sink.Ignore}

    spawn(fn ->
      Creek.Runtime.Process.sink(o, [])
    end)
  end

  def first(ivar) do
    o = %Operator{type: :sink, arg: {ivar, []}, name: "first", ref: Creek.Server.gen_sym(), in: 1, out: 0, impl: Creek.Sink.First}

    spawn(fn ->
      Creek.Runtime.Process.sink(o, [])
    end)
  end

  def last(ivar) do
    o = %Operator{type: :sink, arg: {ivar, []}, name: "first", ref: Creek.Server.gen_sym(), in: 1, out: 0, impl: Creek.Sink.Last}

    spawn(fn ->
      Creek.Runtime.Process.sink(o, [])
    end)
  end

  def tap(pid) do
    o = %Operator{type: :sink, arg: pid, name: "tap", ref: Creek.Server.gen_sym(), in: 1, out: 0, impl: Creek.Sink.Tap}

    spawn(fn ->
      Creek.Runtime.Process.sink(o, [])
    end)
  end
end
