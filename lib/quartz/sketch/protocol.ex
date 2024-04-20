defprotocol Quartz.Sketch.Protocol do
  alias Quartz.Point2D
  alias Dantzig.Polynomial
  alias Quartz.Sketch.BBoxBounds

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

  # @spec bbox_center(t()) :: length()
  # def bbox_center(obj)

  # @spec bbox_horizon(t()) :: length()
  # def bbox_horizon(obj)

  # @spec bbox_top(t()) :: length()
  # def bbox_top(obj)

  # @spec bbox_left(t()) :: length()
  # def bbox_left(obj)

  # @spec bbox_left(t()) :: length()
  # def bbox_right(obj)

  # @spec bbox_bottom(t()) :: length()
  # def bbox_bottom(obj)

  # @spec bbox_height(t()) :: length()
  # def bbox_height(obj)

  @spec bbox_bounds(t()) :: BBoxBounds.t()
  def bbox_bounds(obj)

  @spec transform_lengths(t(), (length() -> length())) :: t()
  def transform_lengths(obj, fun)

  @spec lengths(t()) :: list(number())
  def lengths(obj)

  @spec to_unpositioned_svg(t()) :: any()
  def to_unpositioned_svg(obj)

  @spec to_svg(t()) :: any()
  def to_svg(obj)
end
