defmodule Quartz.Rotations do
  @moduledoc false
  alias Quartz.Point2D
  alias Dantzig.Polynomial
  use Dantzig.Polynomial.Operators

  @deg_to_rad_scale Kernel./(:math.pi(), 180.0)

  # defp cos_degrees(0), do: 1
  # defp cos_degrees(0.0), do: 1.0
  # defp cos_degrees(90), do: 0
  # defp cos_degrees(90.0), do: 0.0
  # defp cos_degrees(180), do: 1
  # defp cos_degrees(180.0), do: 1.0
  # defp cos_degrees(-90), do: 0
  # defp cos_degrees(-90.0), do: 0.0
  # defp cos_degrees(-180), do: -1
  # defp cos_degrees(-180.0), do: -1.0

  defp cos_degrees(angle_in_degrees) do
    angle_in_rads = Polynomial.to_number_if_possible(angle_in_degrees * @deg_to_rad_scale)
    :math.cos(angle_in_rads)
  end

  # defp sin_degrees(0), do: 0
  # defp sin_degrees(0.0), do: 0.0
  # defp sin_degrees(90), do: 1
  # defp sin_degrees(90.0), do: 1.0
  # defp sin_degrees(180), do: 0.0
  # defp sin_degrees(180.0), do: 0.0
  # defp sin_degrees(-90), do: -1
  # defp sin_degrees(-90.0), do: -1.0
  # defp sin_degrees(-180), do: 0
  # defp sin_degrees(-180.0), do: 0.0

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

    reduced_angle_in_degrees =
      case :math.fmod(angle_in_degrees, 360.0) do
        value when value < 0 -> Kernel.+(360.0, value)
        value -> value
      end

    a_x = x
    a_y = y

    b_x = x + width
    b_y = y

    c_x = x + width
    c_y = y + height

    d_x = x
    d_y = y + height

    ra_x = a_x
    ra_y = a_y

    rb_x = (b_x - a_x) * cos - (b_y - a_y) * sin + a_x
    rb_y = (b_y - a_y) * cos + (b_x - a_x) * sin + a_y

    rc_x = (c_x - a_x) * cos - (c_y - a_y) * sin + a_x
    rc_y = (c_y - a_y) * cos + (c_x - a_x) * sin + a_y

    rd_x = (d_x - a_x) * cos - (d_y - a_y) * sin + a_x
    rd_y = (d_y - a_y) * cos + (d_x - a_x) * sin + a_y

    cond do
      0 <= reduced_angle_in_degrees and reduced_angle_in_degrees < 90 ->
        {{rd_x, rb_x}, {ra_y, rc_y}}

      90 <= reduced_angle_in_degrees and reduced_angle_in_degrees < 180 ->
        {{rc_x, ra_x}, {rd_y, rb_y}}

      180 < reduced_angle_in_degrees and reduced_angle_in_degrees < 270 ->
        {{rb_x, rd_x}, {rc_y, ra_y}}

      270 <= reduced_angle_in_degrees and reduced_angle_in_degrees <= 360 ->
        {{ra_x, rc_x}, {rb_y, rd_y}}
    end
  end
end
