defmodule Quartz.Circle do
  alias Quartz.Figure
  alias Quartz.Variable

  defstruct id: nil,
            center_x: nil,
            center_y: nil,
            radius: nil

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

    # Get the next available ID from the figure
    id = Figure.get_id()
    # Create the actual circle
    circle = %__MODULE__{id: id, center_x: center_x, center_y: center_y, radius: radius}
    # Add the circle to the figure
    Figure.add_sketch(id, circle)
    # Return the circle, with no reference to the figure
    circle
  end

  defimpl Quartz.Sketch do
    use Dantzig.Polynomial.Operators
    alias Quartz.Point2D

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
    def solve(circle) do
      solved_center_x = Figure.solve!(circle.center_x)
      solved_center_y = Figure.solve!(circle.center_y)
      solved_radius = Figure.solve!(circle.radius)

      %{circle | center_x: solved_center_x, center_y: solved_center_y, radius: solved_radius}
    end
  end
end
