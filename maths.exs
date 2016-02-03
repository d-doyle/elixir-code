defmodule Maths do
  def zero?(0) do
    true
  end
  def zero?(x) when is_number(x) do
    false
  end
end

Maths.zero?(0)
Maths.zero?(1)
