defmodule Quartz.Point2D do
  @moduledoc false

  alias __MODULE__
  alias Dantzig.Polynomial, as: Poly

  defstruct x: nil,
            y: nil

  def zero(), do: %Point2D{x: 0, y: 0}

  def one(), do: %Point2D{x: 1, y: 1}

  def add(p, q) do
    %Point2D{
      x: Poly.add(p.x, q.x) |> Poly.to_number_if_possible(),
      y: Poly.add(p.y, q.y) |> Poly.to_number_if_possible()
    }
  end

  def subtract(p, q) do
    %Point2D{
      x: Poly.subtract(p.x, q.x) |> Poly.to_number_if_possible(),
      y: Poly.subtract(p.y, q.y) |> Poly.to_number_if_possible()
    }
  end

  def midpoint(p, q) do
    %Point2D{
      x: Poly.add(p.x, q.x) |> Poly.scale(0.5) |> Poly.to_number_if_possible(),
      y: Poly.add(p.y, q.y) |> Poly.scale(0.5) |> Poly.to_number_if_possible()
    }
  end

  def squared_distance(p, q) do
    delta_x = Poly.subtract(p.x, q.x)
    delta_y = Poly.subtract(p.y, q.y)

    Poly.add(
      Poly.multiply(delta_x, delta_x),
      Poly.multiply(delta_y, delta_y)
    )
    |> Poly.to_number_if_possible()
  end

  @doc """
  TODO: implement this in a way that makes sense and plays nicely with Dantzig,
  which by default doesn't support square roots
  """
  def distance(p, q) do
    sq_dist = squared_distance(p, q)

    if is_number(sq_dist) do
      :math.sqrt(sq_dist)
    else
      raise RuntimeError, "Can't be used for points with polynomial coordinates"
    end
  end

  def rotate(p, center_of_rotation, angle_in_degrees) when is_number(angle_in_degrees) do
    # Convert to radians
    angle_in_radians = angle_in_degrees * :math.pi() / 180

    # Because the angle is a numeric value, the sine and cosine are also numeric values
    sin_a = :math.sin(angle_in_radians)
    cos_a = :math.cos(angle_in_radians)

    # However, because the point coordinates may be polynomials,
    # the rotated coordinates may be polynomials themselves and
    # we must use the polynomial functions to deal with them
    # as opposed to the normal numeric operators

    # Cache these values which we'll reuse to save some operations
    # with polynomials and to avoid repeating the code below
    delta_x = Poly.subtract(p.x, center_of_rotation.x)
    delta_y = Poly.subtract(p.y, center_of_rotation.y)

    rotated_x =
      Poly.add(
        Poly.subtract(
          Poly.scale(delta_x, cos_a),
          Poly.scale(delta_y, sin_a)
        ),
        center_of_rotation.x
      )

    rotated_y =
      Poly.add(
        Poly.add(
          Poly.scale(delta_x, sin_a),
          Poly.scale(delta_y, cos_a)
        ),
        center_of_rotation.y
      )

    %Point2D{
      x: rotated_x |> Poly.to_number_if_possible(),
      y: rotated_y |> Poly.to_number_if_possible()
    }
  end
end
