defmodule Todo.Database do
  @db_folder "./persist"
  @db_worker_count 3

  # Interface Functions

  def store(key, data) do
    file_location = file_location_for_key(key)

    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        Todo.DatabaseWorker.store(worker_pid, file_location, data)
      end
    )
  end

  def get(key) do
    file_location = file_location_for_key(key)

    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        Todo.DatabaseWorker.get(worker_pid, file_location)
      end
    )
  end

  # Module Callback Methods

  def child_spec(_) do
    File.mkdir_p!(@db_folder)

    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: Todo.DatabaseWorker,
        size: @db_worker_count
      ],
      [nil]
    )
  end

  # Private Helpers

  defp file_location_for_key(key) do
    Path.join(@db_folder, to_string(key))
  end
end
