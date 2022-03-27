defmodule Todo.List do
  defstruct auto_incrementing_id: 0, entries: %{}

  def add_entry(%__MODULE__{} = todo_list, %Todo.Entry{} = entry) do
    current_id = todo_list.auto_incrementing_id
    new_entries = Map.put(todo_list.entries, current_id, entry)

    %__MODULE__{
      todo_list
      | auto_incrementing_id: current_id + 1,
        entries: new_entries
    }
  end

  def add_entries(%__MODULE__{} = todo_list, []) do
    todo_list
  end

  def add_entries(%__MODULE__{} = todo_list, [%Todo.Entry{} = hdEntry | tailEntries]) do
    todo_list
    |> add_entry(hdEntry)
    |> add_entries(tailEntries)
  end

  def get_entries_by(%__MODULE__{} = todo_list, {:date, %Date{} = date}) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def delete_entry(%__MODULE__{} = todo_list, id) when is_integer(id) do
    new_entries = todo_list.entries |> Map.delete(id)
    %__MODULE__{todo_list | entries: new_entries}
  end
end
