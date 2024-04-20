defmodule Quartz.Sketch.BBoxBounds do
  require Quartz.KeywordSpec, as: KeywordSpec
  import ExUnit.Assertions, only: [assert: 1]

  defstruct x_min: nil,
            x_max: nil,
            y_min: nil,
            y_max: nil

  def new(arguments) do
    # Make sure all arguments are given
    KeywordSpec.validate!(arguments, [!x_min, !x_max, !y_min, !y_max])

    # If both arguments are simple numbers (as opposed to polynomials)
    # ensure that the minimum is less than or equal to the maximum.
    if is_number(x_min) and is_number(x_max) do
      assert x_min <= x_max
    end

    if is_number(y_min) and is_number(y_max) do
      assert y_min <= y_max
    end

    %__MODULE__{
      x_min: x_min,
      x_max: x_max,
      y_min: y_min,
      y_max: y_max
    }
  end
end
