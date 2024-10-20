defprotocol Quartz.Sketch.Protocol do
  @moduledoc """
  A protocol that must be implemented by anything you want to draw on a figure.

  Quartz defines a number of sketches, but nothing forbids you to add more
  as long as you implement this protocol on your struct.
  """
  alias Dantzig.Polynomial
  alias Quartz.Sketch.BBoxBounds

  @type length :: Polynomial.t() | number()

  @spec bbox_bounds(t()) :: BBoxBounds.t()
  def bbox_bounds(obj)

  @doc """
  Transform lengths inside an object, given a length-transformation function.

  This will be used to solve the constraints on your object, when needed.
  """
  @spec transform_lengths(t(), (length() -> length())) :: t()
  def transform_lengths(obj, fun)

  @doc """
  Return lengths that are part of the sketch.
  These will usually be anything that can be measured in units of length.
  """
  @spec lengths(t()) :: list(number())
  def lengths(obj)

  @spec to_unpositioned_svg(t()) :: any()
  def to_unpositioned_svg(obj)

  @spec to_svg(t()) :: any()
  def to_svg(obj)

  @spec assign_measurements_from_resvg_node(t(), %Resvg.Native.Node{}) :: t()
  def assign_measurements_from_resvg_node(obj, resvg_node)
end
