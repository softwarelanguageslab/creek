defmodule CreekTestMeta do
  import Creek.{Wiring, Stream, Node, Meta}
  alias Creek.Meta.Default
  use ExUnit.Case

  # doctest Creek

  def assert_torn_down(stream) do
    Process.sleep(200)

    stream.graph
    |> MutableGraph.map_vertices(fn v ->
      if Process.alive?(v) do
      end

      assert false == Process.alive?(v)
    end)

    if Process.alive?(stream.sink) do
    end

    assert false == Process.alive?(stream.sink)
  end

  def assert_up(stream) do
    Process.sleep(500)

    stream.graph
    |> MutableGraph.map_vertices(fn v ->
      assert true == Process.alive?(v)
    end)

    assert true == Process.alive?(stream.sink)
  end

  # -----------------------------------------------------------------------------
  # Source

  test "single" do
    dag = single(0) |> install(Default)

    stream = run(dag, all() |> install(Default))

    result = get(stream)

    assert result == [0]

    assert_torn_down(stream)
  end

  test "from_list" do
    dag = from_list([1, 2, 3, 4, 5, 6]) |> install(Default)

    stream = run(dag, all() |> install(Default))

    result = get(stream)

    assert result == [1, 2, 3, 4, 5, 6]

    assert_torn_down(stream)
  end

  # -----------------------------------------------------------------------------
  # Mergeg dag

  test "map two upstreams" do
    dag = [single(0), single(0)] ~>> map(fn x -> x + 1 end) |> install(Default)

    stream = run(dag, all() |> install(Default))

    result = get(stream)

    assert result == [1, 1]

    assert_torn_down(stream)
  end

  # -----------------------------------------------------------------------------
  # Operators

  test "map" do
    dag =
      single(0)
      ~> map(fn x -> x + 1 end)
      |> install(Default)

    stream = run(dag, all() |> install(Default))

    result = get(stream)

    assert result == [1]

    assert_torn_down(stream)
  end

  test "double map" do
    dag =
      single(0)
      ~> map(fn x -> x + 1 end)
      ~> map(fn x -> x + 1 end)
      |> install(Default)

    stream = run(dag, all() |> install(Default))

    result = get(stream)

    assert result == [2]

    assert_torn_down(stream)
  end

  test "flatten" do
    dag =
      single(0)
      ~> map(fn _ -> single(0) end)
      ~> flatten()
      ~> map(fn x -> x end)
      |> install(Default)

    stream = run(dag, all() |> install(Default))

    result = get(stream)

    assert result == [0]

    assert_torn_down(stream)
  end

  test "flatten from multiple" do
    dag =
      from_list([1, 2, 3, 4])
      ~> map(fn x -> single(x) end)
      ~> flatten()
      ~> map(fn x -> x end)
      |> install(Default)

    stream = run(dag, all() |> install(Default))

    result = get(stream)

    # Flatten is concurrent so it does not imposen an order!
    assert Enum.sort(result) == [1, 2, 3, 4]

    assert_torn_down(stream)
  end

  # -----------------------------------------------------------------------------
  # Sinks

  test "all" do
    dag = single(0) |> install(Default)

    stream = run(dag, all() |> install(Default))

    result = get(stream)

    assert result == [0]

    assert_torn_down(stream)
  end

  test "head" do
    dag = single(0) |> install(Default)

    stream = run(dag, head() |> install(Default))

    result = get(stream)

    assert result == 0

    assert_torn_down(stream)
  end

  test "fanout 1 branch" do
    dag = single(0) |> install(Default)
    stream = run(dag, fanout() |> install(Default))

    left = extend(stream, map(fn x -> x end), head() |> install(Default))
    assert 0 == get(left)

    assert_torn_down(left)
  end

  test "fanout 2 branches" do
    dag = single(0) |> install(Default)
    stream = run(dag, fanout() |> install(Default))

    left = extend(stream, map(fn x -> x end), head() |> install(Default))
    right = extend(stream, map(fn x -> x end), head() |> install(Default))

    assert 0 = get(left)
    assert 0 == get(right)

    assert_torn_down(stream)
    assert_torn_down(left)
    assert_torn_down(right)
  end

  test "fanout 3 branches" do
    # For this test we assume it's fair that the single has a small delay to ensure the complet message is propagated on time.
    dag = single(0) |> install(Default)
    stream = run(dag, fanout() |> install(Default))

    left = extend(stream, map(fn x -> x end), head() |> install(Default))
    middle = extend(stream, map(fn x -> x end), all() |> install(Default))
    right = extend(stream, map(fn x -> x end), head() |> install(Default))

    assert 0 = get(left)
    assert [0] = get(middle)
    assert 0 == get(right)

    assert_torn_down(stream)
    assert_torn_down(left)
    assert_torn_down(middle)
    assert_torn_down(right)
  end
end
