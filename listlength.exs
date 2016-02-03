defmodule MyList do
  def len([]), do: 0
  def len([ _head | tail ]), do: 1 + len(tail)

  def map([], _func), do: []
  def map([ h | t ], func), do: [ func.(h) | map(t, func) ]
end

IO.puts MyList.len([3, 4, 5, 7])

MyList.map [1, 2, 3, 4, 5], &(&1*&1)
