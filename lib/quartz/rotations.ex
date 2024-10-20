defmodule Quartz.Rotations do
  @moduledoc false

  alias Quartz.Point2D
  alias Quartz.Sketch.BBoxBounds
  import Quartz.Operators, only: [algebra: 1]

  @deg_to_rad_factor Kernel./(:math.pi(), 180.0)

  defp cos_degrees(0), do: 1
  defp cos_degrees(+0.0), do: 1.0
  defp cos_degrees(90), do: 0
  defp cos_degrees(90.0), do: 0.0
  defp cos_degrees(180), do: 1
  defp cos_degrees(180.0), do: 1.0
  defp cos_degrees(-90), do: 0
  defp cos_degrees(-90.0), do: 0.0
  defp cos_degrees(-180), do: -1
  defp cos_degrees(-180.0), do: -1.0

  defp cos_degrees(angle_in_degrees) do
    :math.cos(angle_in_degrees * @deg_to_rad_factor)
  end

  defp sin_degrees(0), do: 0
  defp sin_degrees(+0.0), do: 0.0
  defp sin_degrees(90), do: 1
  defp sin_degrees(90.0), do: 1.0
  defp sin_degrees(180), do: 0.0
  defp sin_degrees(180.0), do: 0.0
  defp sin_degrees(-90), do: -1
  defp sin_degrees(-90.0), do: -1.0
  defp sin_degrees(-180), do: 0
  defp sin_degrees(-180.0), do: 0.0

  defp sin_degrees(angle_in_degrees) do
    :math.sin(angle_in_degrees * @deg_to_rad_factor)
  end

  def rotate_point(%Point2D{} = p, %Point2D{} = center, angle_in_degrees) do
    ct = cos_degrees(angle_in_degrees)
    st = sin_degrees(angle_in_degrees)

    p_x = p.x
    p_y = p.y

    c_x = center.x
    c_y = center.y

    r_x = algebra((p_x - c_x) * ct - (p_y - c_y) * st + c_x)
    r_y = algebra((p_x - c_x) * st + (p_y - c_y) * ct + c_y)

    %Point2D{x: r_x, y: r_y}
  end

  def rotated_text_bounds(text) do
    angle_in_degrees = text.rotation
    # NOTE: not the most efficient way of doing this,
    # but the number of text nodes is expected to be low,
    # so I wouldn't worry much about efficiency here

    # Clamp the angle between 0 and 360 degrees.
    theta =
      case :math.fmod(angle_in_degrees, 360.0) do
        value when value < 0 -> Kernel.+(360.0, value)
        value -> value
      end

    # Cache results into variables to simplify code
    left_bound = text.x
    right_bound = algebra(text.x + text.width)
    top_bound = algebra(text.y - text.height)
    bottom_bound = algebra(text.y + text.depth)

    # The original corners of the text rectangle
    pA = %Point2D{x: left_bound, y: top_bound}
    pB = %Point2D{x: right_bound, y: top_bound}
    pC = %Point2D{x: right_bound, y: bottom_bound}
    pD = %Point2D{x: left_bound, y: bottom_bound}

    # We rotate text around the left end of the baseline
    origin = %Point2D{x: text.x, y: text.y}

    # Rotate points
    rA = rotate_point(pA, origin, angle_in_degrees)
    rB = rotate_point(pB, origin, angle_in_degrees)
    rC = rotate_point(pC, origin, angle_in_degrees)
    rD = rotate_point(pD, origin, angle_in_degrees)

    # From the angle of rotation, we can see which point
    # is at the top, at the right, at the bottom and at the left.
    # The x or y coordinate of those points will be the respective bound.
    {top, right, bottom, left} =
      cond do
        0 <= theta and theta < 90 ->
          {rA, rB, rC, rD}

        90 <= theta and theta < 180 ->
          {rD, rA, rB, rC}

        180 <= theta and theta < 270 ->
          {rD, rC, rA, rB}

        270 <= theta and theta < 360 ->
          {rB, rC, rD, rA}
      end

    # TODO: add visual diagram "proving" this
    # or do the math for all cases and put it in a

    %BBoxBounds{
      x_min: left.x,
      x_max: right.x,
      y_min: top.y,
      y_max: bottom.y,
      baseline: text.y
    }
  end

  def rotated_rectangle_bounds(x, y, width, height, angle_in_degrees)
      when angle_in_degrees == 0.0 or rem(angle_in_degrees, 360) == 0 do
    {{x, x + width}, {y, y + height}}
  end
end
