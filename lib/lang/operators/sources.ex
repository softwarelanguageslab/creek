defmodule Creek.Source do
  alias Creek.Operator

  def single(val) do
    o = %Operator{type: :source, arg: val, name: "single", ref: Creek.Server.gen_sym(), in: 0, out: 1, impl: Creek.Source.Single}

    spawn(fn ->
      Creek.Runtime.Process.source(o, [])
    end)
  end

  def list(xs) do
    o = %Operator{type: :source, arg: xs, name: "list", ref: Creek.Server.gen_sym(), in: 0, out: 1, impl: Creek.Source.List}

    spawn(fn ->
      Creek.Runtime.Process.source(o, [])
    end)
  end

  def subject(description \\ "") do
    o = %Operator{type: :source, arg: nil, name: "subject #{description}", ref: Creek.Server.gen_sym(), in: 0, out: 1, impl: Creek.Source.Subject}

    spawn(fn ->
      Creek.Source.Subject.source(o, [])
    end)
  end

  def subj(description \\ "") do
    o = %Operator{type: :source, arg: nil, name: "subject #{description}", ref: Creek.Server.gen_sym(), in: 0, out: 1, impl: Creek.Source.Subject}

    source =
      spawn(fn ->
        Creek.Source.Subject.source(o, [])
      end)

    sink = fn ->
      o = %Operator{type: :sink, arg: source, name: "funnel" <> description, ref: Creek.Server.gen_sym(), in: 1, out: 0, impl: Creek.Sink.Funnel}

      sink =
        spawn(fn ->
          Creek.Runtime.Process.sink(o, [])
        end)

      sink
    end

    %{sink: sink, source: source}
  end

  def range(a, b, stepsize \\ 1) do
    o = %Operator{type: :source, arg: {a, b, stepsize}, name: "range", ref: Creek.Server.gen_sym(), in: 0, out: 1, impl: Creek.Source.Range}

    spawn(fn ->
      Creek.Runtime.Process.source(o, [])
    end)
  end
end
