defmodule Recursion do
  def factorial(0), do: 1
  def factorial(n), do: n * factorial(n - 1)

  def factorial_tail(n), do: factorial_tail(n, 1)
  defp factorial_tail(0, acc), do: acc
  defp factorial_tail(n, acc), do: factorial_tail(n - 1, acc * n)

  def fibonacci(0), do: 0
  def fibonacci(1), do: 1
  def fibonacci(n), do: fibonacci(n - 1) + fibonacci(n - 2)

  # Once the basic recursive function is found,
  # it becomes easier to transform it into a tail recursive one by moving the accumulationj or  list construction into a temporary variable
  def fibonacci_tail(n), do: fibonacci_tail(n, 1, 0)
  defp fibonacci_tail(0, _, result), do: result
  defp fibonacci_tail(n, next, result) do
    fibonacci_tail(n - 1,  next + result, next)
  end

  def len([]), do: 0
  def len([_|t]), do: 1 + len(t)

  def len_tail(l), do: len_tail(l, 0)
  defp len_tail([], acc), do: acc
  defp len_tail([_|t], acc), do: len_tail(t, acc + 1)

  def duplicate(0, _), do: []
  def duplicate(n, t), do: [t|duplicate(n - 1, t)]

  def duplicate_tail(n, t), do: duplicate_tail(n, t, [])
  defp duplicate_tail(0, _, acc), do: acc
  defp duplicate_tail(n, t, acc), do: duplicate_tail(n - 1, t, [t|acc])

  def reverse([]), do: []
  def reverse([h|t]), do: reverse(t) ++ [h]

  def reverse_tail(l), do: reverse_tail(l, [])
  defp reverse_tail([], acc), do: acc
  defp reverse_tail([h|t], acc), do: reverse_tail(t, [h|acc])

  def sublist(_, 0), do: []
  def sublist([h|t], n), do: [h|sublist(t, n - 1)]

  def sublist_tail(l, n), do: sublist_tail(l, n, []) |> Enum.reverse
  defp sublist_tail(_, 0, acc), do: acc
  defp sublist_tail([h|t], n, acc), do: sublist_tail(t, n - 1, [h|acc])

  def zip([], []), do: []
  def zip([], l), do: l
  def zip(l, []), do: l
  def zip([h|t], [h2|t2]), do: [{h,h2}|zip(t, t2)]

  def zip_tail(l, m), do: zip_tail(l, m, []) |> Enum.reverse
  defp zip_tail([], [], acc), do: acc
  defp zip_tail([h|t], [], acc), do: zip_tail t, [], [h|acc]
  defp zip_tail([], [h|t], acc), do: zip_tail [], t, [h|acc]
  defp zip_tail([h|t], [h2|t2], acc), do: zip_tail t, t2, [{h, h2}|acc]
end

defmodule QuickSort do
  def quicksort([]), do: []
  def quicksort([pivot|rest]) do
    {smaller, larger} = partition pivot, rest, [], []
    quicksort(smaller) ++ [pivot] ++ quicksort(larger)
  end

  defp partition(_, [], smaller, larger), do: {smaller, larger}
  defp partition(pivot, [h|t], smaller, larger) do
    if h <= pivot do
      partition(pivot, t, [h|smaller], larger)
    else
      partition(pivot, t, smaller, [h|larger])
    end
  end

  def lc_quicksort([]), do: []
  def lc_quicksort([pivot|rest]) do
    lc_quicksort(for s <- rest, s <= pivot, do: s) ++ [pivot] ++
      lc_quicksort(for l <- rest, l > pivot, do: l)
  end
end

defmodule Tree do
  def empty(), do: {:node, nil}

  def insert(key, value, {:node, nil}) do
    {:node, {key, value, {:node, nil}, {:node, nil}}}
  end
  def insert(new_key, new_value, {:node, {key, value, smaller, larger}}) when new_key < key do
    {:node, {key, value, insert(new_key, new_value, smaller), larger}}
  end
  def insert(new_key, new_value, {:node, {key, value, smaller, larger}}) when new_key > key do
    {:node, {key, value, smaller, insert(new_key, new_value, larger)}}
  end
  def insert(key, value, {:node, {key, _, smaller, larger}}) do
    {:node, {key, value, smaller, larger}}
  end

  def lookup(_, {:node, nil}), do: :undefined
  def lookup(key, {:node, {key, value, _, _}}), do: {:ok, value}
  def lookup(key, {:node, {node_key, _, smaller, _}}) when key < node_key do
    lookup(key, smaller)
  end
  def lookup(key, {:node, {node_key, _, _, larger}}) when key > node_key do
    lookup(key, larger)
  end
end

IO.puts "Factorial recursive:      " <> inspect :timer.tc(Recursion, :factorial, [300])
IO.puts "Factorial tail recursive: " <> inspect(:timer.tc(Recursion, :factorial_tail, [300])) <> "\n"

IO.puts "Fibonacci recursive:      " <> inspect :timer.tc(Recursion, :fibonacci, [30])
IO.puts "Fibonacci tail recursive: " <> inspect(:timer.tc(Recursion, :fibonacci_tail, [30])) <> "\n"

IO.puts "Length recursive:         " <> inspect Recursion.len [1, 2, 3]
IO.puts "Length tail recursive     " <> inspect(Recursion.len_tail [4, 5, 6]) <> "\n"

IO.puts "Duplicate recursive:      " <> inspect Recursion.duplicate 5, 2
IO.puts "Duplicate tail recursive: " <> inspect(Recursion.duplicate_tail 5, 3) <> "\n"

IO.puts "Reverse recursive:        " <> inspect Recursion.reverse [1, 2, 3]
IO.puts "Reverse tail recursive:   " <> inspect(Recursion.reverse_tail [4, 5, 6]) <> "\n"

IO.puts "SubList recursive:        " <> inspect Recursion.sublist([1, 2, 3], 2)
IO.puts "SubList tail recursive:   " <> inspect(Recursion.sublist_tail([4, 5, 6], 2)) <> "\n"

IO.puts "Zip recursive:            " <> inspect Recursion.zip [1, 2, 3, 4, 5, 6], ["a", "b", "c"]
IO.puts "Zip tail recursive:       " <> inspect(Recursion.zip_tail [1, 2, 3, 4, 5], ["a", "b", "c"]) <> "\n"

IO.puts "Quicksort:                " <> inspect :timer.tc(QuickSort, :quicksort, [[3, 2, 1, 4, 8, 5, 7, 9, 6]])
IO.puts "Quicksort list comp.:     " <> inspect(:timer.tc(QuickSort, :lc_quicksort, [[3, 2, 1, 4, 8, 5, 7, 9, 6]])) <> "\n"

IO.puts inspect t1 = Tree.insert("Jim Woodland", "jim.woodland@gmail.com", Tree.empty())
IO.puts inspect t2 = Tree.insert("Mark Anderson", "i.am.a@hotmail.com", t1)
IO.puts inspect(addresses = Tree.insert("Anita Bath", "abath@someuni.edu",
  Tree.insert("Kevin Robert", "myfairy@yahoo.com", Tree.insert("Wilson Longbrow", "longwil@gmail.com", t2)))) <> "\n"
IO.puts ~s(Tree lookup "Anita Bath":     ) <> inspect(Tree.lookup "Anita Bath", addresses)
IO.puts ~s(Tree lookup "Jacques Requin": ) <> inspect(Tree.lookup "Jacques Requin", addresses)
