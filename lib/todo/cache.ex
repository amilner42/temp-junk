defmodule Todo.Cache do
  def get_server_pid(todo_server_name) do
    case start_child(todo_server_name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  def start_link() do
    IO.puts("Starting to-do cache with `DynamicSupervisor.start_link`...")

    DynamicSupervisor.start_link(
      name: __MODULE__,
      strategy: :one_for_one
    )
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  defp start_child(todo_server_name) do
    DynamicSupervisor.start_child(__MODULE__, {Todo.Server, todo_server_name})
  end
end
