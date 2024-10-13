defprotocol Quartz.Sketch.Protocol do
  alias Dantzig.Polynomial
  alias Quartz.Sketch.BBoxBounds

  @type length :: Polynomial.t() | number()

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

  @spec assign_measurements_from_resvg_node(t(), %Resvg.Native.Node{}) :: t()
  def assign_measurements_from_resvg_node(obj, resvg_node)
end