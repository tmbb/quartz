defmodule Quartz.CountouringTest do
  use ExUnit.Case

  def linear_space(lower, upper, n) do
    delta = upper - lower

    for i <- 0..(n - 1) do
      lower + delta * (i / (n - 1))
    end
  end

  test "countour example" do
    x_coords = linear_space(-:math.pi(), :math.pi(), 50)
    y_coords = linear_space(-:math.pi(), :math.pi(), 50)

    values =
      for x <- x_coords do
        for y <- y_coords do
          :math.cos(x) + :math.sin(y)
        end
      end

    contours = Conrex.conrec(values, x_coords, y_coords, [-0.75, -0.50, 0.0, 0.50, 0.75])
  end
end
