defmodule Creek.Debugger.Router do
  use Plug.Router
  require EEx

  plug(Plug.Static, at: "/", from: :creek)

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, File.read!("debugger/dist/index.html"))
  end

  get "/main.js" do
    send_resp(conn, 200, File.read!("debugger/dist/main.js"))
  end

  match _ do
    send_resp(conn, 404, "404")
  end
end
