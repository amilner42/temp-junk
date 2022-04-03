defmodule Todo.Database do
  @db_folder "./persist"
  @db_worker_count 3

  # Interface Functions

  def store(key, data) do
    file_location = file_location_for_key(key)
    worker_index = worker_index_for_key(key)

    Todo.DatabaseWorker.store(worker_index, file_location, data)
  end

  def get(key) do
    file_location = file_location_for_key(key)
    worker_index = worker_index_for_key(key)

    Todo.DatabaseWorker.get(worker_index, file_location)
  end

  # Module Callback Methods

  defp worker_spec(worker_id) do
    default_worker_spec = {Todo.DatabaseWorker, worker_id}
    Supervisor.child_spec(default_worker_spec, id: worker_id)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  def start_link do
    File.mkdir_p!(@db_folder)

    children = Enum.map(1..@db_worker_count, &worker_spec/1)
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  # Private Helpers

  defp file_location_for_key(key) do
    Path.join(@db_folder, to_string(key))
  end

  defp worker_index_for_key(key) do
    :erlang.phash2(key, @db_worker_count) + 1
  end
end
