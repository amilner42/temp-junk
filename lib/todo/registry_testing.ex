defmodule Looper do
  # Prevent process from ending and infinitely wait for mssg's.
  def looper do
    receive do
      msg ->
        IO.puts("Got mssg: #{msg}")
    end
    looper()
  end

  def main_spawn do
    spawn(fn ->
      Registry.start_link(name: :my_register, keys: :unique)
      Looper.looper()
    end)
  end
end
