defmodule Quartz.Circle do
  alias Quartz.Sketch
  alias Quartz.SVG

  require Quartz.Figure, as: Figure
  require Quartz.KeywordSpec, as: KeywordSpec

  defstruct id: nil,
            center_x: nil,
            center_y: nil,
            radius: nil,
            fill: nil,
            opacity: nil,
            stroke_thickness: 1,
            stroke_paint: nil,
            stroke_dash: nil,
            z_index: 1.0

  def new(opts \\ []) do
    prefix = Keyword.get(opts, :prefix, nil)
    # Assign variables (= Dantzig monomials) to the parameters of the circle
    circle_center_x = Figure.variable("circle_center_x", prefix: prefix)
    circle_center_y = Figure.variable("circle_center_y", prefix: prefix)
    circle_radius = Figure.variable("circle_radius", prefix: prefix)

    KeywordSpec.validate!(opts, [
      fill,
      stroke_paint,
      stroke_dash,
      center_x,
      center_y,
      radius,
      opacity: nil,
      z_index: 1.0,
      stroke_thickness: 1
    ])

    if center_x, do: Figure.assert(circle_center_x == center_x)
    if center_y, do: Figure.assert(circle_center_y == center_y)
    if radius, do: Figure.assert(circle_radius == radius)

    # Get the next available ID from the figure
    id = Figure.get_id()

    # Create the actual circle
    circle = %__MODULE__{
      id: id,
      center_x: circle_center_x,
      center_y: circle_center_y,
      radius: circle_radius,
      fill: fill,
      opacity: opacity,
      stroke_thickness: stroke_thickness,
      stroke_paint: stroke_paint,
      stroke_dash: stroke_dash,
      z_index: z_index
    }

    # Return the circle, with no reference to the figure
    circle
  end

  def draw_new(opts \\ []) do
    circle = new(opts)
    Sketch.draw(circle)
  end

  defimpl Quartz.Sketch.Protocol do
    alias Quartz.Sketch.BBoxBounds
    require Dantzig.Polynomial, as: Polynomial
    use Dantzig.Polynomial.Operators

    @impl true
    def lengths(circle) do
      [circle.center_x, circle.center_y, circle.radius]
    end

    @impl true
    def transform_lengths(circle, fun) do
      transformed_center_x = fun.(circle.center_x)
      transformed_center_y = fun.(circle.center_y)
      transformed_radius = fun.(circle.radius)

      %{
        circle
        | center_x: transformed_center_x,
          center_y: transformed_center_y,
          radius: transformed_radius
      }
    end

    @impl true
    def bbox_bounds(circle) do
      %BBoxBounds{
        x_min: Polynomial.algebra(circle.center_x - circle.radius),
        x_max: Polynomial.algebra(circle.center_x + circle.radius),
        y_min: Polynomial.algebra(circle.center_y - circle.radius),
        y_max: Polynomial.algebra(circle.center_y + circle.radius),
        baseline: Polynomial.algebra(circle.center_y + circle.radius)
      }
    end

    @impl true
    def to_unpositioned_svg(circle) do
      to_svg(circle)
    end

    @impl true
    def to_svg(circle) do
      SVG.circle(
        cx: circle.center_x,
        cy: circle.center_y,
        r: circle.radius,
        fill: circle.fill,
        opacity: circle.opacity,
        stroke: circle.stroke_paint,
        "stroke-width": circle.stroke_thickness
      )
    end

    @impl true
    def assign_measurements_from_resvg_node(circle, _resvg_node) do
      circle
    end
  end
end
