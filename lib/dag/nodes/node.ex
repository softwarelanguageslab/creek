defmodule Creek.Node do
  # -----------------------------------------------------------------------------
  # Source

  def single(value) do
    %{
      :tag => make_ref(),
      :type => :source,
      :name => "single",
      :argument => value,
      :in => 0,
      :out => 1,
      :subscribe => &Creek.Node.Source.Single.subscribe/3,
      :tick => &Creek.Node.Source.Single.tick/2,
      :meta => nil,
      :state => value
    }
  end

  def from_list(xs) do
    %{
      :tag => make_ref(),
      :type => :source,
      :name => "from_list",
      :argument => xs,
      :in => 0,
      :out => 1,
      :subscribe => &Creek.Node.Source.FromList.subscribe/3,
      :tick => &Creek.Node.Source.FromList.tick/2,
      :meta => nil,
      :state => xs
    }
  end

  # -----------------------------------------------------------------------------
  # Operator

  def scan(init, f) do
    %{
      :tag => make_ref(),
      :type => :operator,
      :name => "filter",
      :argument => f,
      :in => 1,
      :out => 1,
      :next => &Creek.Node.Operator.Scan.next/4,
      :complete => &Creek.Node.Operator.Scan.complete/2,
      :meta => nil,
      :state => init
    }
  end

  def filter(f) do
    %{
      :tag => make_ref(),
      :type => :operator,
      :name => "filter",
      :argument => f,
      :in => 1,
      :out => 1,
      :next => &Creek.Node.Operator.Filter.next/4,
      :complete => &Creek.Node.Operator.Filter.complete/2,
      :meta => nil,
      :state => f
    }
  end

  def map(f) do
    %{
      :tag => make_ref(),
      :type => :operator,
      :name => "map",
      :argument => f,
      :in => 1,
      :out => 1,
      :next => &Creek.Node.Operator.Map.next/4,
      :complete => &Creek.Node.Operator.Map.complete/2,
      :meta => nil,
      :state => f
    }
  end

  def flatten() do
    %{
      :tag => make_ref(),
      :type => :operator,
      :name => "flatten",
      :argument => nil,
      :in => 1,
      :out => 1,
      :next => &Creek.Node.Operator.Flatten.next/4,
      :complete => &Creek.Node.Operator.Flatten.complete/2,
      :meta => nil,
      :state => nil
    }
  end

  # -----------------------------------------------------------------------------
  # Sink

  def fanout() do
    %{
      :tag => make_ref(),
      :type => :sink,
      :name => "fanout",
      :argument => nil,
      :in => 1,
      :out => -1,
      :next => &Creek.Node.Sink.FanOut.next/4,
      :complete => &Creek.Node.Sink.FanOut.complete/2,
      :meta => nil,
      :state => nil
    }
  end

  def head() do
    %{
      :tag => make_ref(),
      :type => :sink,
      :name => "head",
      :argument => nil,
      :in => 1,
      :out => 0,
      :next => &Creek.Node.Sink.Head.next/4,
      :complete => &Creek.Node.Sink.Head.complete/2,
      :meta => nil,
      :state => nil
    }
  end

  def all() do
    %{
      :tag => make_ref(),
      :type => :sink,
      :name => "all",
      :argument => nil,
      :in => 1,
      :out => 0,
      :next => &Creek.Node.Sink.All.next/4,
      :complete => &Creek.Node.Sink.All.complete/2,
      :meta => nil,
      :state => []
    }
  end
end
