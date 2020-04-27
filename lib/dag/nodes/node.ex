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
      :subscribe => &Creek.Node.Source.Single.subscribe/1,
      :meta => nil
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
      :subscribe => &Creek.Node.Source.FromList.subscribe/1,
      :meta => nil
    }
  end

  # -----------------------------------------------------------------------------
  # Operator

  def map(f) do
    %{
      :tag => make_ref(),
      :type => :operator,
      :name => "map",
      :argument => f,
      :in => 1,
      :out => 1,
      :next => &Creek.Node.Operator.Map.next/3,
      :complete => &Creek.Node.Operator.Map.complete/2,
      :meta => nil
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
      :next => &Creek.Node.Operator.Flatten.next/3,
      :complete => &Creek.Node.Operator.Flatten.complete/2,
      :meta => nil
    }
  end

  # -----------------------------------------------------------------------------
  # Sink

  def fanout() do
    %{
      :tag => make_ref(),
      :state => nil,
      :type => :sink,
      :name => "fanout",
      :argument => nil,
      :in => 1,
      :out => -1,
      :next => &Creek.Node.Sink.FanOut.next/3,
      :complete => &Creek.Node.Sink.FanOut.complete/2,
      :meta => nil
    }
  end

  def head() do
    %{
      :tag => make_ref(),
      :state => nil,
      :type => :sink,
      :name => "head",
      :argument => nil,
      :in => 1,
      :out => 0,
      :next => &Creek.Node.Sink.Head.next/3,
      :complete => &Creek.Node.Sink.Head.complete/2,
      :meta => nil
    }
  end

  def all() do
    %{
      :tag => make_ref(),
      :state => [],
      :type => :sink,
      :name => "all",
      :argument => nil,
      :in => 1,
      :out => 0,
      :next => &Creek.Node.Sink.All.next/3,
      :complete => &Creek.Node.Sink.All.complete/2,
      :meta => nil
    }
  end
end
