defmodule Creek.Debugger do
  def subject() do
    injector = Creek.Source.subject()

    loop = fn loop ->
      receive do
        m ->
          IO.puts("Emitting message into injector: #{inspect(m)}")
          Creek.Source.Subject.next(injector, m)
      end

      loop.(loop)
    end

    spawn(fn ->
      Phoenix.PubSub.subscribe(Creek.PubSub, "incoming")
      loop.(loop)
    end)

    injector
  end

  def sink() do
    snk =
      Creek.Sink.each(fn x ->
        Phoenix.PubSub.broadcast(Creek.PubSub, "complete", x)
      end)
  end
end
