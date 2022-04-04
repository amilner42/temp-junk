defmodule MyAgent do
  use GenServer

  def start_link(init_state_fn) do
    GenServer.start_link(
      __MODULE__,
      init_state_fn
    )
  end

  def get_state(agent_pid, transformer_fn \\ fn x -> x end) do
    GenServer.call(agent_pid, {:get_state, transformer_fn})
  end

  @impl GenServer
  def init(init_state_fn) do
    send(self(), {:real_init, init_state_fn})
    {:ok, nil}
  end

  @impl GenServer
  def handle_call({:get_state, transformer_fn}, _, state) do
    {:reply, transformer_fn.(state), state}
  end

  @impl GenServer
  def handle_info({:real_init, init_state_fn}, _nullState) do
    init_state = init_state_fn.()
    {:noreply, init_state}
  end
end
