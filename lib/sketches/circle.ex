defmodule Quartz.Circle do
  alias Quartz.Figure
  alias Quartz.Variable

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

    alias Quartz.Typst.TypstAst

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

  defimpl Quartz.Sketch do
    use Dantzig.Polynomial.Operators
    alias Quartz.Point2D
    alias Quartz.Typst.TypstAst

    @impl true
    def top_center(circle) do
      %Point2D{
        x: circle.center_y,
        y: circle.center_y - circle.radius
      }
    end

    @impl true
    def top_right(circle) do
      %Point2D{
        x: circle.center_x + circle.radius,
        y: circle.center_y - circle.radius
      }
    end

    @impl true
    def horizon_right(circle) do
      %Point2D{
        x: circle.center_x + circle.radius,
        y: circle.center_y
      }
    end

    @impl true
    def bottom_right(circle) do
      %Point2D{
        x: circle.center_x + circle.radius,
        y: circle.center_y + circle.radius
      }
    end

    @impl true
    def bottom_center(circle) do
      %Point2D{
        x: circle.center_y,
        y: circle.center_y + circle.radius
      }
    end

    @impl true
    def bottom_left(circle) do
      %Point2D{
        x: circle.center_x - circle.radius,
        y: circle.center_y + circle.radius
      }
    end

    @impl true
    def horizon_left(circle) do
      %Point2D{
        x: circle.center_x - circle.radius,
        y: circle.center_y
      }
    end

    @impl true
    def top_left(circle) do
      %Point2D{
        x: circle.center_x - circle.radius,
        y: circle.center_y - circle.radius
      }
    end

    @impl true
    def bbox_center(circle) do
      circle.center_x
    end

    @impl true
    def bbox_top(circle) do
      circle.center_y - circle.radius
    end

    @impl true
    def bbox_left(circle) do
      circle.center_x - circle.radius
    end

    @impl true
    def bbox_horizon(circle) do
      circle.center_y
    end

    @impl true
    def bbox_right(circle) do
      circle.center_x + circle.radius
    end

    @impl true
    def bbox_bottom(circle) do
      circle.center_y + circle.radius
    end

    @impl true
    def bbox_height(circle) do
      bbox_bottom(circle) - bbox_top(circle)
    end

    @impl true
    def bbox_width(circle) do
      bbox_right(circle) - bbox_left(circle)
    end

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
    def to_typst(circle) do
      circle_stroke_props = [
        thickness: TypstAst.pt(circle.stroke_thickness),
        paint: circle.stroke_paint,
        dash: circle.stroke_dash
      ]

      circle_stroke_props =
        Enum.reject(circle_stroke_props, fn {_key, value} ->
          value == nil
        end)

      stroke_dict = TypstAst.dictionary(circle_stroke_props)

      props = [
        fill: circle.fill,
        stroke: stroke_dict,
        radius: TypstAst.pt(circle.radius)
      ]

      typst_circle =
        TypstAst.function_call(
          TypstAst.variable("circle"),
          TypstAst.named_arguments_from_proplist(props)
        )

      TypstAst.place(
        Kernel.-(circle.center_x, circle.radius),
        Kernel.-(circle.center_y, circle.radius),
        typst_circle
      )
    end
  end
end
