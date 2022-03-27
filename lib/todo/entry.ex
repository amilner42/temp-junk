defmodule Todo.Entry do
  defstruct date: nil, task_name: nil

  def new(%Date{} = date, task_name) when is_bitstring(task_name) do
    %__MODULE__{date: date, task_name: task_name}
  end
end
