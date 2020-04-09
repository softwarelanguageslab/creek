defmodule CreekTest do
  import Creek.{Wiring, Stream, Node}

  use ExUnit.Case

  # doctest Creek

  def assert_torn_down(stream) do
    Process.sleep(300)

    stream.graph
    |> MutableGraph.map_vertices(fn v ->
      assert false == Process.alive?(v)
    end)

    assert false == Process.alive?(stream.sink)
  end

  def assert_up(stream) do
    Process.sleep(300)

    stream.graph
    |> MutableGraph.map_vertices(fn v ->
      assert true == Process.alive?(v)
    end)

    assert true == Process.alive?(stream.sink)
  end

  # -----------------------------------------------------------------------------
  # Source
  test "single" do
    dag = single(1)

    stream = run(dag, all())

    result = get(stream)

    assert result == [1]

    assert_torn_down(stream)
  end

  # -----------------------------------------------------------------------------
  # Operators
  test "map" do
    dag = single(1) ~> map(fn x -> x + 1 end)

    stream = run(dag, all())

    result = get(stream)

    assert result == [2]

    assert_torn_down(stream)
  end

  # -----------------------------------------------------------------------------
  # Sinks

  test "all" do
    dag = single(1)

    stream = run(dag, all())

    result = get(stream)

    assert result == [1]

    assert_torn_down(stream)
  end

  test "head" do
    dag = single(1)

    stream = run(dag, head())

    result = get(stream)

    assert result == 1

    assert_torn_down(stream)
  end

  @tag :failing
  test "fanout 1 branch" do
    dag = single(1)
    stream = run(dag, fanout())

    left = extend(stream, map(fn x -> x end), head())
    assert 1 == get(left)

    assert_torn_down(left)
  end

  test "fanout 2 branches" do
    dag = single(1)
    stream = run(dag, fanout())

    left = extend(stream, map(fn x -> x end), head())
    right = extend(stream, map(fn x -> x end), head())

    assert 1 = get(left)
    assert 1 == get(right)

    assert_up(stream)
    assert_torn_down(left)
    assert_torn_down(right)
  end

  test "fanout 3 branches" do
    dag = single(1)
    stream = run(dag, fanout())

    left = extend(stream, map(fn x -> x end), head())
    middle = extend(stream, map(fn x -> x end), all())
    right = extend(stream, map(fn x -> x end), head())

    assert 1 = get(left)
    assert [1] = get(middle)
    assert 1 == get(right)

    assert_up(stream)
    assert_torn_down(left)
    assert_torn_down(middle)
    assert_torn_down(right)
  end
end
