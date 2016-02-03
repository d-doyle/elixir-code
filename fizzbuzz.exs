defmodule FizzBuzz do
  def upto(n) when n > 0, do: _upto(1, n, [])

  defp _upto(_, 0, result), do: Enum.reverse(result)

  defp _upto(current, left, result) do
    next = 
      cond do
        rem(current, 3) == 0 and rem(current, 5) == 0 -> "Fizzbuzz"
        rem(current, 3) == 0 -> "Fizz"
        rem(current, 5) == 0 -> "Buzz"
        true -> current
      end
    _upto(current+1, left-1, [next | result])
  end

  def upto2(n) when n > 0, do: _upto2(1, n, [])

  defp _upto2(current, n, result) when current > n, do: Enum.reverse(result)
  defp _upto2(current, n, result) do
    next = 
      cond do
          rem(current, 3) == 0 and rem(current, 5) == 0 -> "Fizzbuzz"
          rem(current, 3) == 0 -> "Fizz"
          rem(current, 5) == 0 -> "Buzz"
          true -> current
      end
    _upto2(current+1, n, [next | result])
  end

  def upto_down(n) when n > 0, do: _downto(n, [])

  defp _downto(0, result), do: result

  defp _downto(current, result) do
    next = 
      cond do
          rem(current, 3) == 0 and rem(current, 5) == 0 -> "Fizzbuzz"
          rem(current, 3) == 0 -> "Fizz"
          rem(current, 5) == 0 -> "Buzz"
          true -> current
      end
    _downto(current-1, [next | result])
  end

  def upto_case(n) when n > 0, do: _upto_case(n, [])

  defp _upto_case(0, result), do: result

  defp _upto_case(current, result) do
    next = 
      case {rem(current, 3), rem(current, 5), current} do
        {0, 0, _} -> "FizzBuzz"
        {0, _, _} -> "Fizz"
        {_, 0, _} -> "Buzz"
        {_, _, n} -> n
      end
    _upto_case(current-1, [next | result])
  end

  def upto_guard(n) when n > 0 do
    Enum.map(1..n, &_upto_guard/1)
  end

  defp _upto_guard(n) when rem(n, 3) == 0 and rem(n, 5) == 0, do: "FizzBuzz"
  defp _upto_guard(n) when rem(n, 3) == 0, do: "Fizz"
  defp _upto_guard(n) when rem(n, 5) == 0, do: "Buzz"
  defp _upto_guard(n), do: n
end
