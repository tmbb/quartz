defmodule Quartz.Rotations do
  @moduledoc false

  alias Quartz.Point2D
  alias Dantzig.Polynomial
  use Dantzig.Polynomial.Operators

  @deg_to_rad_scale Kernel./(:math.pi(), 180.0)

  defp cos_degrees(0), do: 1
  defp cos_degrees(+0.0), do: 1.0
  defp cos_degrees(-0.0), do: 1.0
  defp cos_degrees(90), do: 0
  defp cos_degrees(90.0), do: 0.0
  defp cos_degrees(180), do: 1
  defp cos_degrees(180.0), do: 1.0
  defp cos_degrees(-90), do: 0
  defp cos_degrees(-90.0), do: 0.0
  defp cos_degrees(-180), do: -1
  defp cos_degrees(-180.0), do: -1.0

  defp cos_degrees(angle_in_degrees) do
    angle_in_rads = Polynomial.to_number_if_possible(angle_in_degrees * @deg_to_rad_scale)
    :math.cos(angle_in_rads)
  end

  defp sin_degrees(0), do: 0
  defp sin_degrees(+0.0), do: 0.0
  defp sin_degrees(-0.0), do: 0.0
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
    y_r = (p.x - center.x) * st + (p.y - center.y) * ct + center.y

    %Point2D{x: x_r, y: y_r}
  end

  def rotated_rectangle_bounds(x, y, width, height, angle_in_degrees)
      when angle_in_degrees == 0.0 or rem(angle_in_degrees, 360) == 0 do
    {{x, x + width}, {y, y + height}}
  end

  def rotated_rectangle_bounds(x, y, width, height, angle_in_degrees) do
    cos = cos_degrees(angle_in_degrees)
    sin = sin_degrees(angle_in_degrees)

    theta =
      case :math.fmod(angle_in_degrees, 360.0) do
        value when value < 0 -> Kernel.+(360.0, value)
        value -> value
      end

    h = height
    w = width

    cond do
      0 <= theta and theta < 90 ->
        {{0 + x, w * cos + h * sin + x}, {0 + y, w * sin + h * cos + y}}

      90 <= theta and theta < 180 ->
        {{w * cos + x, h * sin + x}, {w * cos + y, w * sin + y}}

      180 < theta and theta < 270 ->
        {{w * cos + h * sin + x, 0 + x}, {w * sin + h * cos + y, 0 + y}}

      270 <= theta and theta <= 360 ->
        {{h * sin + x, w * cos + x}, {w * sin + y, h * cos + y}}
    end
  end
end
