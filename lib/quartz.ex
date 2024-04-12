defmodule Quartz do
  @moduledoc """
  Documentation for `Quartz`.
  """

  def f(x, y) do
    :math.pow(:math.cos(2*x) + 1.5 * :math.cos(1.5*y), 2)
  end

  def test() do
    n = 50

    x_min = 0.0
    x_max = :math.pi
    delta_x = x_max - x_min

    y_min = 0.0
    y_max = :math.pi
    delta_y = y_max - y_min

    xs = for i <- 0..(n - 1), do: x_min + delta_x * i
    ys = for j <- 0..(n - 1), do: y_min + delta_y * j
    values =
      for x <- xs do
        for y <- ys do
          f(x, y)
        end
      end

    Conrex.conrec(values, xs, ys, [0.0, 0.2, 0.4, 0.6, 0.8, 1.0])
  end
end
