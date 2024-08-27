defmodule Quartz.Length do
  @moduledoc """
  Units of measurement for lengths.

  ## Implementation note

  In Quartz, all lengths are represented in points (pt)
  as floating point values. They are unitless.
  The functions in this module return unitless values
  in points by applying the proper conversion factor
  to their arguments.
  """

  @cm_factor 72 / 2.54
  @mm_factor 72 / 25.4
  @inch_factor 72

  @doc """
  Distance in inches.
  """
  def inch(value), do: @inch_factor * value

  @doc """
  Distance in points (72pt = 1in).
  """
  def pt(value), do: value

  @doc """
  Distance in millimeters.
  """
  def mm(value), do: @mm_factor * value

  @doc """
  Distance in centimeters.
  """
  def cm(value), do: @cm_factor * value
end
