defmodule Fib do
  def fib(0), do: 0
  def fib(1), do: 1
  def fib(n), do: fib(n - 1) + fib(n - 2)
end

defmodule FibTail do
  # Once the basic recursive function is found,
  # it becomes easier to transform it into a tail recursive one by moving the accumulationj or  list construction into a temporary variable
  def fib(n) do
    fib(n, 1, 0)
  end

  defp fib(0, _, result) do
    result
  end

  defp fib(n, next, result) do
    IO.puts "n: #{n} next: #{next} result: #{result}"
    fib(n - 1,  next + result, next)
  end
end

IO.puts inspect :timer.tc(Fib, :fib, [30])
IO.puts inspect :timer.tc(FibTail, :fib, [30])
