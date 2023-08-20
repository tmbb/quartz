defmodule Quartz.Rotations do
  @moduledoc false
  alias Quartz.Point2D
  alias Dantzig.Polynomial
  use Dantzig.Polynomial.Operators

  @deg_to_rad_scale Kernel./(:math.pi(), 180.0)

  defp cos_degrees(0), do: 1
  defp cos_degrees(0.0), do: 1.0
  defp cos_degrees(90), do: 0
  defp cos_degrees(90.0), do: 0.0
  defp cos_degrees(180), do: 1
  defp cos_degrees(180.0), do: 1.0
  defp cos_degrees(-90), do: 0
  defp cos_degrees(-90.0), do: 0.0
  defp cos_degrees(-180), do: -1
  defp cos_degrees(-180.0), do: 1.0

  defp cos_degrees(angle_in_degrees) do
    angle_in_rads = Polynomial.to_number_if_possible(angle_in_degrees * @deg_to_rad_scale)
    :math.cos(angle_in_rads)
  end

  defp sin_degrees(0), do: 0
  defp sin_degrees(0.0), do: 0.0
  defp sin_degrees(90), do: 1
  defp sin_degrees(90.0), do: 1.0
  defp sin_degrees(180), do: 0.0
  defp sin_degrees(180.0), do: 0.0
  defp sin_degrees(-90), do: -1
  defp sin_degrees(-90.0), do: -1.0
  defp sin_degrees(-180), do: 0
  defp sin_degrees(-180.0), do: 0.0

  defp sin_degrees(angle_in_degrees) do
    angle_in_rads = Polynomial.to_number_if_possible(angle_in_degrees * @deg_to_rad_scale)
    :math.sin(angle_in_rads)
  end

  def rotate_point(%Point2D{} = p, %Point2D{} = center, angle_in_degrees) do
    ct = cos_degrees(angle_in_degrees)
    st = sin_degrees(angle_in_degrees)

    x_r = (p.x - center.x) * ct - (p.y - center.y) * st + center.x
    y_r = (p.x - center.x) * st + (p.y - center.y) * st + center.y

    %Point2D{x: x_r, y: y_r}
  end

  def rotated_rectangle_bounds(x, y, width, height, angle_in_degrees)
      when angle_in_degrees in [0, 0.0] do
    {{x, x + width}, {y, y + height}}
  end

  def rotated_rectangle_bounds(x, y, width, height, angle_in_degrees) do
    ct = cos_degrees(angle_in_degrees)
    st = sin_degrees(angle_in_degrees)

    # cos = cos_degrees(angle_in_degrees)
    # sin = sin_degrees(angle_in_degrees)

    hct = height * ct
    wct = width * ct
    hst = height * st
    wst = width * st

    cond do
      0 < angle_in_degrees and angle_in_degrees < 90 ->
        y_min = y
        y_max = y + hct + wst
        x_min = x - hst
        x_max = x + wct

        {{x_min, x_max}, {y_min, y_max}}

      90 <= angle_in_degrees and angle_in_degrees <= 180 ->
        y_min = y + hct
        y_max = y + wst
        x_min = x - hst + wct
        x_max = x

        {{x_min, x_max}, {y_min, y_max}}

      -90 < angle_in_degrees and angle_in_degrees <= 0 ->
        y_min = y + wst
        y_max = y + hct
        x_min = x
        x_max = x + wct - hst

        {{x_min, x_max}, {y_min, y_max}}

      -180 <= angle_in_degrees and angle_in_degrees <= -90 ->
        y_min = y + wst + hct
        y_max = y
        x_min = x + wct
        x_max = x - hst

        {{x_min, x_max}, {y_min, y_max}}
    end
  end
end
