defmodule Quartz.Canvas do
  alias Quartz.Figure
  alias Quartz.Variable
  alias Quartz.Length
  alias Quartz.Color.RGB
  alias Quartz.SVG
  alias Quartz.Point2D

  @debug_stroke %{
    thickness: Length.pt(0.5),
    paint: RGB.gray(),
    dash: "dotted"
  }

  defstruct id: nil,
            x: nil,
            y: nil,
            width: nil,
            height: nil,
            stroke: nil,
            contents: nil

  def new(opts \\ []) do
    prefix = Keyword.get(opts, :prefix, nil)
    # Assign variables (= Dantzig monomials) to the parameters of the canvas
    x = Variable.maybe_variable(opts, :x, Variable.maybe_with_prefix(prefix, "canvas_x"), [])
    y = Variable.maybe_variable(opts, :y, Variable.maybe_with_prefix(prefix, "canvas_y"), [])

    height =
      Variable.maybe_variable(opts, :height, Variable.maybe_with_prefix(prefix, "canvas_height"),
        min: 0
      )

    width =
      Variable.maybe_variable(opts, :width, Variable.maybe_with_prefix(prefix, "canvas_width"),
        min: 0
      )

    stroke =
      case Keyword.fetch(opts, :stroke) do
        {:ok, value} ->
          value

        :error ->
          case Figure.debug?() do
            true -> @debug_stroke
            false -> nil
          end
      end

    # Get the next available ID from the figure
    id = Figure.get_id()

    # Create the actual canvas
    canvas = %__MODULE__{
      id: id,
      x: x,
      y: y,
      height: height,
      width: width,
      stroke: stroke
    }

    # Add the canvas to the figure
    Figure.add_sketch(id, canvas)

    # Return the canvas, with no reference to the figure
    canvas
  end

  defimpl Quartz.Sketch.Protocol do
    use Dantzig.Polynomial.Operators
    alias Quartz.Sketch.BBoxBounds

    @impl true
    def bbox_bounds(canvas) do
      %BBoxBounds{
        x_min: canvas.x,
        x_max: canvas.x + canvas.width,
        y_min: canvas.y,
        y_max: canvas.y + canvas.height
      }
    end

    @impl true
    def lengths(canvas) do
      [canvas.x, canvas.y, canvas.width, canvas.height]
    end

    @impl true
    def transform_lengths(canvas, fun) do
      transformed_x = fun.(canvas.x)
      transformed_y = fun.(canvas.y)
      transformed_width = fun.(canvas.width)
      transformed_height = fun.(canvas.height)

      %{
        canvas
        | x: transformed_x,
          y: transformed_y,
          width: transformed_width,
          height: transformed_height
      }
    end

    @impl true
    def to_unpositioned_svg(canvas) do
      to_svg(canvas)
    end

    @impl true
    def to_svg(canvas) do
      if canvas.stroke do
        thickness = Access.get(canvas.stroke, :thickness, 0.75)
        paint = Access.get(canvas.stroke, :paint, "gray")

        SVG.rect(
          id: canvas.id,
          x: canvas.x,
          y: canvas.y,
          width: canvas.width,
          height: canvas.height,
          stroke: paint
        )
      else
        SVG.g([id: canvas.id], [])
      end
    end
  end
end
