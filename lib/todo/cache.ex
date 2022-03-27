defmodule Todo.Cache do
  use GenServer

  # Helper methods

  def start() do
    Todo.Database.start()
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def get_server_pid(todo_server_name) do
    GenServer.call(__MODULE__, {:get_server_pid, todo_server_name})
  end

  # Callback module Methods

  @impl GenServer
  def init(_) do
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:get_server_pid, todo_server_name}, _, pid_by_todo_server_name_state) do
    case Map.get(pid_by_todo_server_name_state, todo_server_name) do
      nil ->
        {:ok, pid} = Todo.Server.start(todo_server_name)

        new_pid_by_todo_server_name_state =
          Map.put(pid_by_todo_server_name_state, todo_server_name, pid)

        {:reply, pid, new_pid_by_todo_server_name_state}

      pid ->
        {:reply, pid, pid_by_todo_server_name_state}
    end
  end
end
