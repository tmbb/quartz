defmodule Quartz.Sketch do
  alias Quartz.Point2D
  require Dantzig.Polynomial, as: Polynomial
  # alias Quartz.Sketch.BBoxBounds
  alias Quartz.Sketch.Protocol
  alias Quartz.SVG

  @type t() :: any()
  @type length :: Polynomial.t() | number()

  # @spec top_center(t()) :: Point2D.t()
  # def top_center(obj)

  # @spec top_right(t()) :: Point2D.t()
  # def top_right(obj)

  # @spec horizon_right(t()) :: Point2D.t()
  # def horizon_right(obj)

  # @spec bottom_right(t()) :: Point2D.t()
  # def bottom_right(obj)

  # @spec bottom_center(t()) :: Point2D.t()
  # def bottom_center(obj)

  # @spec bottom_left(t()) :: Point2D.t()
  # def bottom_left(obj)

  # @spec horizon_left(t()) :: Point2D.t()
  # def horizon_left(obj)

  # @spec top_left(t()) :: Point2D.t()
  # def top_left(obj)

  @spec bbox_center(t()) :: length()
  def bbox_center(obj) do
    bounds = Protocol.bbox_bounds(obj)
    # lower y is a higher on the page
    Polynomial.algebra(0.5 * (bounds.x_min + bounds.x_max))
  end

  @spec bbox_horizon(t()) :: length()
  def bbox_horizon(obj) do
    bounds = Protocol.bbox_bounds(obj)
    # lower y is a higher on the page
    Polynomial.algebra(0.5 * (bounds.y_min + bounds.y_max))
  end

  @spec bbox_top(t()) :: length()
  def bbox_top(obj) do
    bounds = Protocol.bbox_bounds(obj)
    # lower y is a higher on the page
    bounds.y_min
  end

  @spec bbox_right(t()) :: length()
  def bbox_right(obj) do
    bounds = Protocol.bbox_bounds(obj)
    bounds.x_max
  end

  @spec bbox_left(t()) :: length()
  def bbox_left(obj) do
    bounds = Protocol.bbox_bounds(obj)
    bounds.x_min
  end

  @spec bbox_bottom(t()) :: length()
  def bbox_bottom(obj) do
    bounds = Protocol.bbox_bounds(obj)
    # higher y is a lower on the page
    bounds.y_max
  end

  @spec bbox_height(t()) :: length()
  def bbox_height(obj) do
    bounds = Protocol.bbox_bounds(obj)
    Polynomial.algebra(bounds.y_max - bounds.y_min)
  end

  @spec bbox_width(t()) :: length()
  def bbox_width(obj) do
    bounds = Protocol.bbox_bounds(obj)
    Polynomial.algebra(bounds.x_max - bounds.x_min)
  end

  @spec bbox_bounds(t()) :: length()
  def bbox_bounds(obj) do
    Protocol.bbox_bounds(obj)
  end

  @spec to_unpositioned_svg(t()) :: SVG.t()
  def to_unpositioned_svg(obj) do
    Protocol.to_unpositioned_svg(obj)
  end

  @spec to_svg(t()) :: SVG.t()
  def to_svg(obj) do
    Protocol.to_svg(obj)
  end

  @spec to_unpositioned_svg(t()) :: SVG.t()
  def to_unpositioned_svg(obj) do
    Protocol.to_unpositioned_svg(obj)
  end

  @spec transform_lengths(t(), (length() -> length())) :: t()
  def transform_lengths(obj, fun) do
    Protocol.transform_lengths(obj, fun)
  end

  @spec lengths(t()) :: list(length())
  def lengths(obj) do
    Protocol.lengths(obj)
  end
end
