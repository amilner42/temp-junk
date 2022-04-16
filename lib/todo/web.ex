defmodule Todo.Web do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  def child_spec(_) do
    Plug.Adapters.Cowboy.child_spec(
      scheme: :http,
      options: [port: Application.fetch_env!(:todo, :http_port)],
      plug: __MODULE__
    )
  end

  post "/add_entry" do
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")
    task_name = Map.fetch!(conn.params, "task_name")
    date = Date.from_iso8601!(Map.fetch!(conn.params, "date"))

    list_name
    |> Todo.Cache.get_server_pid()
    |> Todo.Server.add_entry(Todo.Entry.new(date, task_name))

    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, "OK")
  end

  get "/entries" do
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")
    date = Date.from_iso8601!(Map.fetch!(conn.params, "date"))

    entries =
      list_name
      |> Todo.Cache.get_server_pid()
      |> Todo.Server.get_entries_by({:date, date})

    formatted_entries =
      entries
      |> Enum.map(&"#{&1.date} #{&1.task_name}")
      |> Enum.join("\n")

    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, formatted_entries)
  end
end
