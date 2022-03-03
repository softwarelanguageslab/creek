defmodule Creek.Operator do
  # import Creek.DSL

  defstruct opts: [], arg: nil, name: nil, ref: nil, in: 0, out: 0, label: "", impl: nil, meta: nil, type: nil, meta_sink: [], meta_in: []

  alias __MODULE__

  def map(f, opts \\ []) do
    %Creek.Operator{opts: opts, type: :operator, arg: f, name: "map", ref: Creek.Server.gen_sym(), in: 1, out: 1, impl: Creek.Operator.Map}
  end

  def take(n, opts \\ []) do
    %Creek.Operator{opts: opts, type: :operator, arg: n, name: "take-#{inspect(n)}", ref: Creek.Server.gen_sym(), in: 1, out: 1, impl: Creek.Operator.TakeN}
  end

  def filter(f, opts \\ []) do
    %Creek.Operator{opts: opts, type: :operator, arg: f, name: "filter", ref: Creek.Server.gen_sym(), in: 1, out: 1, impl: Creek.Operator.Filter}
  end

  def debug() do
    %Creek.Operator{
      opts: [],
      type: :operator,
      arg: fn x ->
        IO.inspect(x, label: "debug")
        x
      end,
      name: "debug",
      ref: Creek.Server.gen_sym(),
      in: 1,
      out: 1,
      impl: Creek.Operator.Map
    }
  end

  def zip(opts \\ []) do
    %Creek.Operator{
      type: :operator,
      arg: %{0 => [], 1 => []},
      name: "zip",
      ref: Creek.Server.gen_sym(),
      in: 2,
      out: 1,
      impl: Creek.Operator.Zip
    }
  end

  def zipLatest(opts \\ []) do
    %Creek.Operator{
      type: :operator,
      arg: %{0 => nil, 1 => nil},
      name: "zipLatest",
      ref: Creek.Server.gen_sym(),
      in: 2,
      out: 1,
      impl: Creek.Operator.ZipLatest
    }
  end

  def zipRight(opts \\ []) do
    %Creek.Operator{
      type: :operator,
      arg: %{0 => [], 1 => []},
      name: "zipLatest",
      ref: Creek.Server.gen_sym(),
      in: 2,
      out: 1,
      impl: Creek.Operator.ZipRight
    }
  end

  def fold(proc, init \\ nil) do
    %Creek.Operator{
      type: :operator,
      arg: {proc, init},
      name: "fold",
      ref: Creek.Server.gen_sym(),
      in: 1,
      out: 1,
      impl: Creek.Operator.Fold
    }
  end

  def merge(n \\ 2) do
    merge(n, [])
  end

  def merge(n, opts) do
    %Creek.Operator{
      opts: opts,
      type: :operator,
      arg: %{0 => [], 1 => []},
      name: "merge",
      ref: Creek.Server.gen_sym(),
      in: n,
      out: 1,
      impl: Creek.Operator.Merge
    }
  end

  def dup(n \\ 2) do
    dup(n, [])
  end

  def dup(n, opts) do
    %Creek.Operator{opts: opts, type: :operator, arg: nil, name: "dup", ref: Creek.Server.gen_sym(), in: 1, out: n, impl: Creek.Operator.Dup}
  end

  # def balance(n \\ 2) do
  #   balance(n, [])
  # end

  # def balance(n, opts) do
  #   filters =
  #     1..(n - 1)
  #     |> Enum.reduce(filter(fn {tag, _v} -> tag == 0 end) ~> map(fn {_tag, v} -> v end), fn i, acc ->
  #       op = filter(fn {tag, _v} -> tag == i end) ~> map(fn {_tag, v} -> v end)
  #       acc ||| op
  #     end)

  #   op =
  #     transform(0, fn x, state ->
  #       tag = rem(state + 1, n)
  #       {tag, {tag, x}}
  #     end)
  #     ~> dup(n)
  #     ~> filters

  #   op
  # end

  def transform(state, proc, opts \\ []) do
    %Creek.Operator{opts: opts, type: :operator, arg: {state, proc}, name: "transform", ref: Creek.Server.gen_sym(), in: 1, out: 1, impl: Creek.Operator.Transform}
  end

  def dummy(name) do
    %Creek.Operator{type: :operator, arg: nil, name: "dummy", label: name, ref: Creek.Server.gen_sym(), in: 1, out: 1}
  end

  def actor_src() do
    %Creek.Operator{type: :actor_source, arg: nil, name: "actor_src", ref: Creek.Server.gen_sym(), in: 0, out: 1}
  end

  def actor_snk() do
    %Creek.Operator{type: :actor_sink, arg: nil, name: "actor_snk", ref: Creek.Server.gen_sym(), in: 1, out: 0}
  end

  ##############################################################################
  # Helpers
  def ensure_dag(%Creek.Operator{} = o) do
    GatedDag.new()
    |> GatedDag.add_vertex(o, o.in, o.out)
  end

  def ensure_dag({_, _, dag}) do
    dag
  end

  def ensure_dag(%GatedDag{} = g) do
    g
  end

  #############################################################################
  # Derived

  def average(last \\ 0) do
    transform({nil, nil}, fn v, {count, sum} ->
      if count == nil and sum == nil do
        {{1, v}, v}
      else
        count = if count >= last, do: count + 1, else: 1
        sum = if count >= last, do: v, else: sum + v

        {{count, sum}, sum / count}
      end
    end)
  end
end
