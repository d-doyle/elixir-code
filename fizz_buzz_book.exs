
  _fizzbuzz = fn
    (0, 0, _) -> "FizzBuzz"
    (0, _, _) -> "Fizz"
    (_, 0, _) -> "Buzz"
    (_, _, x) -> x
  end

  fizzbuzz = fn (n) ->
    _fizzbuzz.(rem(n, 3), rem(n, 5), n)
  end

1..30 |> Enum.map(&fizzbuzz.(&1)) |> IO.inspect
