defmodule Todo.Server do
  use GenServer

  # Helper methods

  def start(todo_server_name) do
    IO.puts("Starting todo server #{todo_server_name}")
    GenServer.start(__MODULE__, todo_server_name)
  end

  def add_entry(server_pid, entry) do
    GenServer.cast(server_pid, {:add_entry, entry})
  end

  def get_entries_by(server_pid, params) do
    GenServer.call(server_pid, {:get_entries_by, params})
  end

  # Callback module methods

  @impl GenServer
  def init(todo_server_name) do
    send(self(), :real_init)
    {:ok, {todo_server_name, nil}}
  end

  @impl GenServer
  def handle_cast({:add_entry, entry}, {todo_server_name, todo_list}) do
    new_todo_list = Todo.List.add_entry(todo_list, entry)
    Todo.Database.store(todo_server_name, new_todo_list)

    {:noreply,
     {
       todo_server_name,
       new_todo_list
     }}
  end

  @impl GenServer
  def handle_cast({:add_entries, entries}, {todo_server_name, todo_list}) do
    new_todo_list = Todo.List.add_entries(todo_list, entries)
    Todo.Database.store(todo_server_name, new_todo_list)

    {:noreply,
     {
       todo_server_name,
       new_todo_list
     }}
  end

  @impl GenServer
  def handle_call({:get_entries_by, params}, _, {todo_server_name, todo_list_state}) do
    entries = Todo.List.get_entries_by(todo_list_state, params)

    {:reply, entries,
     {
       todo_server_name,
       todo_list_state
     }}
  end

  @impl GenServer
  def handle_info(:real_init, {todo_server_name, _}) do
    starting_todo_list = Todo.Database.get(todo_server_name) || %Todo.List{}
    {:noreply, {todo_server_name, starting_todo_list}}
  end
end
