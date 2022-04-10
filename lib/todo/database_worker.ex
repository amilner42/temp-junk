defmodule Todo.DatabaseWorker do
  use GenServer

  def start_link(_) do
    IO.puts("Starting database worker...")
    GenServer.start_link(__MODULE__, nil)
  end

  def store(worker_pid, file_location, data) do
    GenServer.cast(worker_pid, {:store, file_location, data})
  end

  def get(worker_pid, file_location) do
    GenServer.call(worker_pid, {:get, file_location})
  end

  # Callback module methods

  def init(_) do
    {:ok, nil}
  end

  def handle_cast({:store, file_location, data}, state) do
    File.write!(file_location, :erlang.term_to_binary(data))

    {:noreply, state}
  end

  def handle_call({:get, file_location}, _, state) do
    data =
      case File.read(file_location) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    {:reply, data, state}
  end
end
