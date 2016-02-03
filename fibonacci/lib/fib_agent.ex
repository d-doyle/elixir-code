defmodule FibAgent do
  # Define a function to start the agent
  def start_link do
    # Load the cache with the initial values
    cache = Enum.into([{0, 0}, {1, 1}], HashDict.new)
    # Load the cache into the agent
    Agent.start_link(fn -> cache end)
  end

  def fib(pid, n) when n >= 0 do
    # Get and update the agent's state
    Agent.get_and_update(pid, &do_fib(&1, n))
  end

  defp do_fib(cache, n) do
    if cached = cache[n] do
      {cached, cache}
    else
      # else calculate fibonacci for n - 1
      {val, cache} = do_fib(cache, n - 1)
      # result = val + cache
      result = val + cache[n - 2]
      # return result and cache
      {result, Dict.put(cache, n, result)}
    end
  end
end

{:ok, agent} = FibAgent.start_link()
IO.puts FibAgent.fib(agent, 1000)
