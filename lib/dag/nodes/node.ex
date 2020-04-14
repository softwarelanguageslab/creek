defmodule Creek.Node do
  # -----------------------------------------------------------------------------
  # Source

  def single(value) do
    %{
      :type => :source,
      :name => "single",
      :argument => value,
      :in => 0,
      :out => 1,
      :subscribe => &Creek.Node.Source.Single.subscribe/2
    }
  end

  def from_list(xs) do
    %{
      :type => :source,
      :name => "from_list",
      :argument => xs,
      :in => 0,
      :out => 1,
      :subscribe => &Creek.Node.Source.FromList.subscribe/2
    }
  end

  # -----------------------------------------------------------------------------
  # Operator

  def map(f) do
    %{
      :type => :operator,
      :name => "map",
      :argument => f,
      :in => 1,
      :out => 1,
      :next => &Creek.Node.Operator.Map.next/3,
      :complete => &Creek.Node.Operator.Map.complete/3
    }
  end

  def flatten() do
    %{
      :type => :operator,
      :name => "flatten",
      :argument => nil,
      :in => 1,
      :out => 1,
      :next => &Creek.Node.Operator.Flatten.next/3,
      :complete => &Creek.Node.Operator.Flatten.complete/3
    }
  end

  # -----------------------------------------------------------------------------
  # Sink

  def fanout() do
    %{
      :state => nil,
      :type => :sink,
      :name => "fanout",
      :argument => nil,
      :in => 1,
      :out => -1,
      :next => &Creek.Node.Sink.FanOut.next/4,
      :complete => &Creek.Node.Sink.FanOut.complete/2
    }
  end

  def head() do
    %{
      :state => nil,
      :type => :sink,
      :name => "head",
      :argument => nil,
      :in => 1,
      :out => 0,
      :next => &Creek.Node.Sink.Head.next/4,
      :complete => &Creek.Node.Sink.Head.complete/2
    }
  end

  def all() do
    %{
      :state => [],
      :type => :sink,
      :name => "all",
      :argument => nil,
      :in => 1,
      :out => 0,
      :next => &Creek.Node.Sink.All.next/4,
      :complete => &Creek.Node.Sink.All.complete/2
    }
  end
end
