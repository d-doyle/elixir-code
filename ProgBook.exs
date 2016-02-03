defmodule ProgBook do
  def fact(0), do: 1
  def fact(n) when n > 0 do n * fact(n - 1) end

  def sumn(0), do: 0
  def sumn(n), do: n + sumn(n - 1)

  def gcd(x, 0), do: x
  def gcd(x, y), do: gcd(y, rem(x, y))
end

IO.inspect ProgBook.fact 5

defmodule Chop do
  def guess(n, low..high), do: find_match(n, div(low + high, 2), low..high)

  def find_match(n, n, _) do
    IO.puts "Is it #{n}?"
    IO.puts n
  end
  def find_match(n, g, _low..high) when g < n do
    IO.puts "Is it #{g}?"
    #IO.puts "It is between #{g} and #{high}"
    find_match(n, div(g + high, 2), g..high)
  end#
  def find_match(n, g, low.._high) when g > n do
    IO.puts "Is it #{g}?"
    #IO.puts "It is between #{low} and #{g}"
    find_match(n, div(low + g, 2), low..g)
  end
end

Chop.guess(273, 1..1000)

defmodule MyList do
  def len([]), do: 0
  def len([_head | tail]), do: 1 + len(tail)

  def square([]), do: []
  def square([head | tail]), do: [ head * head | square(tail)]

  def map([], _func), do: []
  def map([head | tail], func), do: [ func.(head) | map(tail, func)]

  def sum(list), do: _sum(list, 0)
  defp _sum([], total), do: total
  defp _sum([head | tail], total), do: _sum(tail, head + total)

  def sum_n([]), do: 0
  def sum_n([head | tail]), do: head + sum_n(tail)

  def mapsum([], _func), do: 0
  def mapsum([head | tail], func), do: func.(head) + mapsum(tail, func)

  def max(list), do: _max(list, 0)
  defp _max([], m), do: m
  defp _max([head | tail], m) when m === 0 or m < head do
    _max(tail, head)
  end
  defp _max([head | tail], m) when m >= head do
    _max(tail, m)
  end

  def span(n, n), do: [n]
  def span(from, to) when from < to, do: [from | span(from + 1, to)]
  def span(from, to) when from > to, do: [to | span(from, to + 1)]

  def primes_up_to(n) do
    range = MyList.span(2, n)
    range -- for a <- range, b <- range, a <= b, a * b <= n, do: a * b
  end
end

IO.inspect MyList.len [1, 2, 3]
IO.inspect MyList.square [1, 2, 3]
IO.inspect MyList.map [1, 2, 3], fn n -> n * n end
IO.inspect MyList.sum [1, 2, 3]
IO.inspect MyList.sum_n [1, 2, 3]
IO.inspect MyList.mapsum [1, 2, 3], &(&1 * &1)
IO.inspect MyList.max [-1, -2, -3]
IO.inspect MyList.span(-5, 1)
IO.inspect MyList.primes_up_to 100

defmodule MyEnum do
  def all?([], _func), do: true
  def all?([head | tail], func) do
    func.(head) and all?(tail, func)
  end

  def each([], _func), do: []
  def each([head | tail], func), do: [func.(head) | each(tail, func)]

  def filter([], _func), do: []
  def filter([head | tail], func) do
    if func.(head) do
      [head | filter(tail, func)]
    else
      filter(tail, func)
    end
  end

  def split(list, count), do: _split(list, [], count)

  defp _split([], front, _), do: [ Enum.reverse(front), [] ]
  defp _split(tail, front, 0), do: [ Enum.reverse(front), tail]
  defp _split([head | tail], front, count), do: _split(tail, [head | front], count - 1)
end

IO.inspect MyEnum.all? Enum.to_list(1..5), &(&1 > 0)
IO.inspect MyEnum.each Enum.to_list(1..5), &(&1 * &1)
IO.inspect MyEnum.filter Enum.to_list(1..5), &(rem(&1, 2) !== 0)
IO.inspect MyEnum.split Enum.to_list(1..10), 5
Stream.unfold({0, 1}, fn {f1, f2} -> {f1, {f2, f1 + f2}} end) |> Enum.take(15) |> IO.inspect

defmodule Countdown do
  def sleep(seconds) do
    receive do
    after
      seconds*1000 -> nil
    end
  end

  def say(text) do
    spawn fn -> :os.cmd('espeak #{text}') end
  end

  def timer do
    Stream.resource(
      fn ->
        {_h, _m, s} = :erlang.time
        60 - s - 1
      end,
      fn
        0 ->
          {:halt, 0}
        count ->
          sleep(1)
          { [inspect(count)], count - 1 }
      end,
      fn _ -> end
    )
  end
end

#Countdown.timer |>
#Stream.each(&IO.puts/1) |>
#Stream.each(&Countdown.say/1) |>
#Enum.take(5)

defmodule Tax do
  def orders_with_total(orders, tax_rates) do
    #{:ok, file} = File.open("Orders.csv", [:write, :utf8])
    #IO.puts(file, "id, ship_to, net_amount")
    orders |> Enum.map(&add_total_to(&1, tax_rates)) #, file))
    #File.close(file)
  end

  def add_total_to(order = [id: id, ship_to: state, net_amount: net], tax_rates) do
    #IO.puts(file, "#{id}, #{state}, #{net}")
    tax_rate = Keyword.get(tax_rates, state, 0)
    total_amount = net + net * tax_rate
    Keyword.put(order, :total_amount, total_amount)
    IO.puts("#{id}, #{state}, #{net}, #{tax_rate},  #{total_amount}")
    #IO.puts(file, "#{id}, #{state}, #{net}, #{tax_rate},  #{total_amount}")
  end

  def read_orders_file(fileName, tax_rates) do
    {:ok, file} = File.open(fileName, [:read, :utf8])
    headers = read_header(IO.gets(file, :line))
    orders = Enum.map(IO.stream(file, :line), &create_one_row(headers, &1))
    orders_with_total(orders, tax_rates)
    File.close(file)
  end

  defp read_header(line) do
    from_csv_and_map(line, &String.to_atom(&1))
  end
  
  defp create_one_row(headers, line) do
    row = from_csv_and_map(line, &convert_numbers(&1))
    Enum.zip(headers, row)
  end

  defp from_csv_and_map(line, func) do
    line |> String.strip |> String.split(~r{,\s*}) |> Enum.map(func)
  end

  defp convert_numbers(value) do
    cond do
      Regex.match?(~r{^\d+$}, value) -> {num, _} = Integer.parse(value); num
      Regex.match?(~r{^\d*\.\d+$}, value) -> {num, _} = Float.parse(value); num
      << name :: binary >> = value -> String.to_atom(name)
      # ?: :: utf8,
      true -> value
    end
  end
end

tax_rates =  [ NC: 0.075, TX: 0.08 ]

orders = [
  [ id: 123, ship_to: :NC, net_amount: 100.00 ],
  [ id: 124, ship_to: :OK, net_amount:  35.50 ],
  [ id: 125, ship_to: :TX, net_amount:  24.00 ],
  [ id: 126, ship_to: :TX, net_amount:  44.80 ],
  [ id: 127, ship_to: :NC, net_amount:  25.00 ],
  [ id: 128, ship_to: :MA, net_amount:  10.00 ],
  [ id: 129, ship_to: :CA, net_amount: 102.00 ],
  [ id: 130, ship_to: :NC, net_amount:  50.00 ]
]

Tax.orders_with_total(orders, tax_rates)
Tax.read_orders_file("Orders.csv", tax_rates)

defmodule Parse do
  def number([ ?- | tail ]), do: number(tail) * -1
  def number([ ?+ | tail ]), do: number(tail)
  def number(str), do: _number_digits(str, 0)

  defp _number_digits([], value), do: value
  defp _number_digits([ digit | tail ], value) when digit in '0123456789' do
      _number_digits(tail, value * 10 + digit - ?0)
  end
  defp _number_digits([ non_digit | _ ], _) do
    raise "Invalid digit '#{[non_digit]}'"
  end

  def ascii?([]), do: true
  def ascii?([ digit | tail ]) when digit >= ?\s or digit <= ?~ do
    ascii?(tail)
  end
  def ascii?(_), do: false

  def anagram?(word_a, word_b) do
    signature(word_a) == signature(word_b)
  end
  defp signature(word) do 
    word |> to_char_list |> Enum.sort |> to_string
  end

  def calculate(expression) do
    { n1, rest } = parse_number(expression)
    rest = ltrim(rest)
    { op, rest } = parse_operator(rest)
    rest = ltrim(rest)
    { n2, [] } = parse_number(rest)
    op.(n1, n2)
  end

  defp parse_number(expression), do: _parse_number({ 0, expression })
  defp _parse_number({ value, [ digit | rest ]}) when digit in ?0..?9 do
    _parse_number({ value * 10 + digit - ?0, rest })
  end
  defp _parse_number(result) do result end

  defp ltrim([ ?\s | rest ]), do: ltrim(rest)
  defp ltrim(rest), do: rest

  defp parse_operator([ ?+ | rest ]), do: { &(&1 + &2), rest}
  defp parse_operator([ ?- | rest ]), do: { &(&1 - &2), rest}
  defp parse_operator([ ?* | rest ]), do: { &(&1 * &2), rest}
  defp parse_operator([ ?/ | rest ]), do: { &(&1 / &2), rest}
end

IO.inspect Parse.number '123456'
IO.inspect Parse.number '-123'

IO.inspect Parse.ascii?('abc123')
IO.inspect Parse.anagram?("cat", "act")
IO.inspect Parse.anagram?("sun", "dog")

IO.inspect Parse.calculate('23 + 32')


defmodule MyString do
  # capitalize_sentences("oh. a DOG. woof.")
  def capitalize_sentences(sentences) do
    sentences
    |> String.split(~r{\.\s+}) 
    |> Enum.map(&String.capitalize(&1)) 
    |> Enum.join(". ")
  end
end

IO.puts MyString.capitalize_sentences("oh. a DOG. woof.")

defmodule OkTest do
  def ok!({:ok, data}), do: data

  def ok!({state, data}) do 
    raise("#{state}: #{data}")
  end
end
