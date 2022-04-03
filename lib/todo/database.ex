defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"
  @db_worker_count 3

  def start_link(_) do
    IO.puts("Starting database...")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  def get(key) do
    file_location = file_location_for_key(key)
    db_worker_pid = GenServer.call(__MODULE__, {:get_db_worker_pid, key})

    GenServer.call(db_worker_pid, {:get, file_location})
  end

  # Module callback methods

  def init(_) do
    File.mkdir_p!(@db_folder)
    worker_pid_by_index = start_workers()
    {:ok, worker_pid_by_index}
  end

  def handle_cast({:store, key, data}, worker_pid_by_index) do
    file_location = file_location_for_key(key)
    db_worker_index = worker_index_for_key(key)
    db_worker_pid = Map.fetch!(worker_pid_by_index, db_worker_index)

    :ok = GenServer.cast(db_worker_pid, {:store, file_location, data})
    {:noreply, worker_pid_by_index}
  end

  def handle_call({:get_db_worker_pid, key}, _, worker_pid_by_index) do
    db_worker_index = worker_index_for_key(key)
    db_worker_pid = Map.fetch!(worker_pid_by_index, db_worker_index)

    {:reply, db_worker_pid, worker_pid_by_index}
  end

  defp file_location_for_key(key) do
    Path.join(@db_folder, to_string(key))
  end

  defp start_workers() do
    Enum.reduce(
      0..(@db_worker_count - 1),
      %{},
      fn index, acc ->
        {:ok, db_worker_pid} = Todo.DatabaseWorker.start_link()
        Map.put(acc, index, db_worker_pid)
      end
    )
  end

  defp worker_index_for_key(key) do
    :erlang.phash2(key, @db_worker_count)
  end
end
