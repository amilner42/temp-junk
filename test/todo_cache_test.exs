defmodule TodoCacheTest do
  use ExUnit.Case

  test "server_process" do
    {:ok, _} = Todo.Cache.start()

    pid_1 = Todo.Cache.get_server_pid("arie-list-1")
    pid_2 = Todo.Cache.get_server_pid("arie-list-2")

    assert pid_1 === pid_2
  end

  test "other" do
    apiResponse = {:error, "api error reason..."}
    assert {:ok, _} = apiResponse
  end
end
