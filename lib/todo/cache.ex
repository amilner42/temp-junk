defmodule Todo.Cache do
  use GenServer

  # Helper methods

  def start_link(_) do
    IO.puts("Starting to-do cache with `start_link`...")
    # Doing this lead to a very confusing bug where killing the worker with:
    #
    #  Process.exit(Process.whereis(Todo.Database), :asdf)
    #
    # Did not reboot everything! Because it was linking it to the calling process
    # which must have been the supervisor, who, must have ignored the death
    # given it is not a direct child.
    #
    # To add to my confusion, when starting without the supervisor, killing
    # the database did kill everything making me feel it was indeed connected
    # and it was a supervisor-issue. By directly calling start_link from the
    # repl, it must be the repl process that "connected" everything and
    # therefore they all crash when one crashes.
    #
    # Todo.Database.start_link()
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def get_server_pid(todo_server_name) do
    GenServer.call(__MODULE__, {:get_server_pid, todo_server_name})
  end

  # Callback module Methods

  @impl GenServer
  def init(_) do
    send(self(), :real_init)
    {:ok, %{}}
  end

  @impl GenServer
  def handle_info(:real_init, state) do
    Todo.Database.start_link()
    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:get_server_pid, todo_server_name}, _, pid_by_todo_server_name_state) do
    case Map.get(pid_by_todo_server_name_state, todo_server_name) do
      nil ->
        {:ok, pid} = Todo.Server.start_link(todo_server_name)

        new_pid_by_todo_server_name_state =
          Map.put(pid_by_todo_server_name_state, todo_server_name, pid)

        {:reply, pid, new_pid_by_todo_server_name_state}

      pid ->
        {:reply, pid, pid_by_todo_server_name_state}
    end
  end
end
