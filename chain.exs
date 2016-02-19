defmodule Chain do
  @moduledoc """
  Create a chain of processes and have each one increment a value
  """

  def counter (next_pid) do
    receive do
      # Increment n and pass the result to the next pid
      n -> send next_pid, n + 1
    end
  end

  def create_processes(n) do
    # Spawn n processes passing our process id to the first
    # The value passed to each subsequent spawned process will be the pid returned by spawn
    last = Enum.reduce 1..n, self,
      fn (_, send_to) ->
        spawn(Chain, :counter, [send_to])
      end

      # Start the count by sending zero to the last spawned process
      send last, 0

      receive do
        final_answer when is_integer(final_answer) ->
          "Result is #{inspect(final_answer)}"
      end
  end

  def run(n) do
    # Display the time and value returned after creating n processes
    IO.puts inspect :timer.tc(Chain, :create_processes, [n])
  end
end
