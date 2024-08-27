defmodule Quartz do
  @moduledoc """
  Documentation for `Quartz`.
  """

  def f(x, y) do
    :math.pow(:math.cos(2 * x) + 1.5 * :math.cos(1.5 * y), 2)
  end
end
