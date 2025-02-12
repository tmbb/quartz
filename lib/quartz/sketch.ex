defmodule Quartz.Sketch do
  require Dantzig.Polynomial, as: Polynomial
  # alias Quartz.Sketch.BBoxBounds
  alias Quartz.Text
  alias Quartz.Sketch.Protocol
  alias Quartz.SVG
  alias Quartz.Figure

  @type t() :: any()
  @type length :: Polynomial.t() | number()

  @spec draw(t()) :: t()
  def draw(obj) do
    Figure.add_sketch(obj.id, obj)

    # Put this in the protocol instead of hardcoding the case of %Text{}
    case obj do
      %Text{} ->
        Figure.add_unmeasured_item(obj)

      _other ->
        :ok
    end

    obj
  end

  @spec bbox_baseline(t()) :: length()
  def bbox_baseline(obj) do
    bounds = Protocol.bbox_bounds(obj)
    bounds.baseline
  end

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

  @spec to_svg(t() | binary()) :: SVG.t()
  def to_svg(obj) do
    case obj do
      bin when is_binary(bin) ->
        SVG.escaped_iodata(bin)

      other ->
        Protocol.to_svg(other)
    end
  end

  @spec transform_lengths(t(), (length() -> length())) :: t()
  def transform_lengths(obj, fun) do
    Protocol.transform_lengths(obj, fun)
  end

  @spec lengths(t()) :: list(length())
  def lengths(obj) do
    Protocol.lengths(obj)
  end

  @spec assign_measurements_from_resvg_node(t(), %Resvg.Native.Node{}) :: t()
  def assign_measurements_from_resvg_node(obj, resvg_node) do
    Protocol.assign_measurements_from_resvg_node(obj, resvg_node)
  end
end
