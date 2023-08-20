defmodule Quartz.Length do
  @cm_factor 72 / 2.54
  @mm_factor 72 / 25.4
  @inch_factor 72

  def inch(value), do: @inch_factor * value
  def pt(value), do: value
  def mm(value), do: @mm_factor * value
  def cm(value), do: @cm_factor * value
end
