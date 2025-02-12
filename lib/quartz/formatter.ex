defmodule Quartz.Formatter do
  @moduledoc """
  Functions to help display floats and dates.
  """

  @float_decimals 5

  @doc """
  A function to display rounded length with a given number of decimals.

  This is used mainly when rendering sketches to SVG.
  The goal of defining this function here is to centralize the default number
  of decimal places for floats that are used as part of drawing dimensions.

  This function is public API and is meant to be used by end users
  who might want to implement new sketches.
  """
  def rounded_length(float, decimals \\ @float_decimals)

  def rounded_length(value, _decimals) when is_integer(value), do: to_string(value)

  def rounded_length(float, decimals) when is_float(float) do
    :erlang.float_to_binary(float, decimals: decimals)
  end

  @doc """
  Display a float rounded to the given number of decimals.
  """
  def rounded_float(float, nr_of_decimal_places, format \\ :normal) do
    (float * 1.0)
    |> Decimal.from_float()
    |> Decimal.round(nr_of_decimal_places, :half_even)
    |> Decimal.to_string(format)
  end
end
