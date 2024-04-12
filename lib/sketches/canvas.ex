defmodule Quartz.Canvas do
  alias Quartz.Figure
  alias Quartz.Variable
  alias Quartz.Length
  alias Quartz.Color.RGB

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

  defimpl Quartz.Sketch do
    use Dantzig.Polynomial.Operators
    alias Quartz.Point2D
    alias Quartz.Typst.TypstAst

    defp horizontal_center(canvas) do
      (canvas.x + canvas.width) * 0.5
    end

    defp vertical_center(canvas) do
      (canvas.y + canvas.height) * 0.5
    end

    @impl true
    def top_center(canvas) do
      %Point2D{
        x: horizontal_center(canvas),
        y: canvas.y
      }
    end

    @impl true
    def top_right(canvas) do
      %Point2D{
        x: canvas.x + canvas.width,
        y: canvas.y
      }
    end

    @impl true
    def horizon_right(canvas) do
      %Point2D{
        x: canvas.x + canvas.width,
        y: vertical_center(canvas)
      }
    end

    @impl true
    def bottom_right(canvas) do
      %Point2D{
        x: canvas.x + canvas.width,
        y: canvas.y + canvas.height
      }
    end

    @impl true
    def bottom_center(canvas) do
      %Point2D{
        x: horizontal_center(canvas),
        y: canvas.y + canvas.height
      }
    end

    @impl true
    def bottom_left(canvas) do
      %Point2D{
        x: canvas.x,
        y: canvas.y + canvas.height
      }
    end

    @impl true
    def horizon_left(canvas) do
      %Point2D{
        x: canvas.x,
        y: vertical_center(canvas)
      }
    end

    @impl true
    def top_left(canvas) do
      %Point2D{
        x: canvas.x,
        y: canvas.y + canvas.height
      }
    end

    @impl true
    def bbox_center(canvas) do
      0.5 * (bbox_left(canvas) + bbox_right(canvas))
    end

    @impl true
    def bbox_horizon(canvas) do
      0.5 * (bbox_top(canvas) + bbox_bottom(canvas))
    end

    @impl true
    def bbox_top(canvas) do
      canvas.y
    end

    @impl true
    def bbox_left(canvas) do
      canvas.x
    end

    @impl true
    def bbox_right(canvas) do
      canvas.x + canvas.width
    end

    @impl true
    def bbox_bottom(canvas) do
      canvas.y + canvas.height
    end

    @impl true
    def bbox_height(canvas) do
      bbox_bottom(canvas) - bbox_top(canvas)
    end

    @impl true
    def bbox_width(canvas) do
      bbox_right(canvas) - bbox_left(canvas)
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
    def to_typst(canvas) do
      stroke =
        if canvas.stroke do
          # Get the parameters for the stroke
          thickness = Access.get(canvas.stroke, :thickness, 0.75)
          paint = Access.get(canvas.stroke, :paint, TypstAst.variable("gray"))
          dash = Access.get(canvas.stroke, :dash, "dotted")

          # NOTE: we can't just feed the stroke map into the TypstAst.dictionary/1
          # function because there is no way to tell Typst that the thickness
          # is a length. Lengths in Quartz are represented just like any
          # other number (there is currently no good way around it)
          TypstAst.dictionary(
            thickness: TypstAst.pt(thickness),
            paint: paint,
            dash: dash
          )
        else
          :none
        end

      box =
        TypstAst.function_call(
          TypstAst.variable("rect"),
          TypstAst.named_arguments_from_proplist(
            stroke: stroke,
            width: TypstAst.pt(canvas.width),
            height: TypstAst.pt(canvas.height)
          )
        )

      TypstAst.place(
        canvas.x,
        canvas.y,
        box
      )
    end
  end
end
