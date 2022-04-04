defmodule Todo.Server do
  use Agent, restart: :temporary

  # Helper methods

  def start_link(todo_server_name) do
    Agent.start_link(
      fn ->
        IO.puts("Starting todo server with agent: #{todo_server_name}")
        starting_todo_list = Todo.Database.get(todo_server_name) || %Todo.List{}
        {todo_server_name, starting_todo_list}
      end,
      name: via_tuple(todo_server_name)
    )
  end

  def add_entry(server_pid, entry) do
    Agent.cast(server_pid, fn {todo_server_name, todo_list} ->
      new_todo_list = Todo.List.add_entry(todo_list, entry)
      Todo.Database.store(todo_server_name, new_todo_list)
      {todo_server_name, new_todo_list}
    end)
  end

  def add_entries(server_pid, entries) do
    Agent.cast(server_pid, fn {todo_server_name, todo_list} ->
      new_todo_list = Todo.List.add_entries(todo_list, entries)
      Todo.Database.store(todo_server_name, new_todo_list)

      {todo_server_name, new_todo_list}
    end)
  end

  def get_entries_by(server_pid, params = {:date, _date}) do
    Agent.get(server_pid, fn {_todo_server_name, todo_list} ->
      Todo.List.get_entries_by(todo_list, params)
    end)
  end

  # Private

  defp via_tuple(todo_server_name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, todo_server_name})
  end
end
