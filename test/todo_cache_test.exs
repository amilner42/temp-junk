defmodule TodoCacheTest do
  use ExUnit.Case

  test "server_process" do
    pid_1 = Todo.Cache.get_server_pid("arie-list-1")
    pid_2 = Todo.Cache.get_server_pid("arie-list-2")

    assert pid_1 !== pid_2
  end
end
