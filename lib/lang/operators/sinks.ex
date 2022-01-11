defmodule Creek.Sink do
  alias Creek.Operator

  def all(ivar) do
    o = %Operator{type: :sink, arg: {ivar, []}, name: "all", ref: Creek.Server.gen_sym(), in: 1, out: 0, impl: Creek.Sink.All}

    spawn(fn ->
      Creek.Runtime.Process.sink(o, [])
    end)
  end

  def each(proc) do
    o = %Operator{type: :sink, arg: proc, name: "each", ref: Creek.Server.gen_sym(), in: 1, out: 0, impl: Creek.Sink.Each}

    spawn(fn ->
      Creek.Runtime.Process.sink(o, [])
    end)
  end

  def ignore(pid) do
    o = %Operator{type: :sink, arg: pid, name: "ignore", ref: Creek.Server.gen_sym(), in: 1, out: 0, impl: Creek.Sink.Ignore}

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

  def funnel(subject, tag \\ "a funnel") do
    o = %Operator{type: :sink, arg: subject, name: "funnel" <> tag, ref: Creek.Server.gen_sym(), in: 1, out: 0, impl: Creek.Sink.Funnel}

    spawn(fn ->
      Creek.Runtime.Process.sink(o, [])
    end)
  end
end
