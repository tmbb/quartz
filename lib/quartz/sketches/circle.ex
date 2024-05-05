defmodule Quartz.Circle do
  alias Quartz.Figure
  alias Quartz.Variable
  alias Quartz.SVG
  require Quartz.KeywordSpec, as: KeywordSpec

  defstruct id: nil,
            center_x: nil,
            center_y: nil,
            radius: nil,
            fill: nil,
            stroke_thickness: 1,
            stroke_paint: nil,
            stroke_dash: nil,
            z_level: 1.0

  def new(opts \\ []) do
    prefix = Keyword.get(opts, :prefix, nil)
    # Assign variables (= Dantzig monomials) to the parameters of the circle
    center_x =
      Variable.maybe_variable(
        opts,
        :center_x,
        Variable.maybe_with_prefix(prefix, "circle_center_x"),
        []
      )

    center_y =
      Variable.maybe_variable(
        opts,
        :center_y,
        Variable.maybe_with_prefix(prefix, "circle_center_y"),
        []
      )

    radius =
      Variable.maybe_variable(opts, :radius, Variable.maybe_with_prefix(prefix, "circle_radius"),
        min: 0
      )

    KeywordSpec.validate!(opts, [
      fill,
      stroke_paint,
      stroke_dash,
      z_level: 1.0,
      stroke_thickness: 1
    ])

    # Get the next available ID from the figure
    id = Figure.get_id()

    # Create the actual circle
    circle = %__MODULE__{
      id: id,
      center_x: center_x,
      center_y: center_y,
      radius: radius,
      fill: fill,
      stroke_thickness: stroke_thickness,
      stroke_paint: stroke_paint,
      stroke_dash: stroke_dash,
      z_level: z_level
    }

    # Add the circle to the figure
    Figure.add_sketch(id, circle)

    # Return the circle, with no reference to the figure
    circle
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
        x_min: Polynomial.algebra(circle.x - circle.radius),
        x_max: Polynomial.algebra(circle.x + circle.radius),
        y_min: Polynomial.algebra(circle.y - circle.radius),
        y_max: Polynomial.algebra(circle.y + circle.radius),
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
        stroke: circle.stroke_paint,
        "stroke-width": circle.stroke_thickness
      )
    end
  end
end
