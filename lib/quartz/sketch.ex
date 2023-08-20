defprotocol Quartz.Sketch do
  alias Quartz.Point2D
  alias Dantzig.Polynomial
  alias Quartz.AxisData

  @spec top_center(t()) :: Point2D.t()
  def top_center(obj)

  @spec top_right(t()) :: Point2D.t()
  def top_right(obj)

  @spec horizon_right(t()) :: Point2D.t()
  def horizon_right(obj)

  @spec bottom_right(t()) :: Point2D.t()
  def bottom_right(obj)

  @spec bottom_center(t()) :: Point2D.t()
  def bottom_center(obj)

  @spec bottom_left(t()) :: Point2D.t()
  def bottom_left(obj)

  @spec horizon_left(t()) :: Point2D.t()
  def horizon_left(obj)

  @spec top_left(t()) :: Point2D.t()
  def top_left(obj)

  @spec bbox_center(t()) :: Polynomial.t() | number()
  def bbox_center(obj)

  @spec bbox_horizon(t()) :: Polynomial.t() | number()
  def bbox_horizon(obj)

  @spec bbox_top(t()) :: Polynomial.t() | number()
  def bbox_top(obj)

  @spec bbox_left(t()) :: Polynomial.t() | number()
  def bbox_left(obj)

  @spec bbox_left(t()) :: Polynomial.t() | number()
  def bbox_right(obj)

  @spec bbox_bottom(t()) :: Polynomial.t() | number()
  def bbox_bottom(obj)

  @spec bbox_height(t()) :: Polynomial.t() | number()
  def bbox_height(obj)

  @spec bbox_width(t()) :: Polynomial.t() | number()
  def bbox_width(obj)

  @spec solve(t()) :: t()
  def solve(obj)

  @spec lengths(t()) :: list(number())
  def lengths(obj)

  # @spec apply_scale(t(), AxisData.t(), any()) :: t()
  # def apply_scale(obj, axis_data, scale)

  @spec to_typst(t()) :: any()
  def to_typst(obj)
end
