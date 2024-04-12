defmodule Quartz.Container do
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
    # Assign variables (= Dantzig monomials) to the parameters of the container
    x = Variable.maybe_variable(opts, :x, Variable.maybe_with_prefix(prefix, "container_x"), [])
    y = Variable.maybe_variable(opts, :y, Variable.maybe_with_prefix(prefix, "container_y"), [])

    height =
      Variable.maybe_variable(
        opts,
        :height,
        Variable.maybe_with_prefix(prefix, "container_height"),
        min: 0
      )

    width =
      Variable.maybe_variable(opts, :width, Variable.maybe_with_prefix(prefix, "container_width"),
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

    # Create the actual container
    container = %__MODULE__{
      id: id,
      x: x,
      y: y,
      height: height,
      width: width,
      stroke: stroke
    }

    # Add the container to the figure
    Figure.add_sketch(id, container)

    # Return the container, with no reference to the figure
    container
  end

  defimpl Quartz.Sketch do
    use Dantzig.Polynomial.Operators
    alias Quartz.Point2D
    alias Quartz.Typst.TypstAst

    defp horizontal_center(container) do
      (container.x + container.width) * 0.5
    end

    defp vertical_center(container) do
      (container.y + container.height) * 0.5
    end

    @impl true
    def top_center(container) do
      %Point2D{
        x: horizontal_center(container),
        y: container.y
      }
    end

    @impl true
    def top_right(container) do
      %Point2D{
        x: container.x + container.width,
        y: container.y
      }
    end

    @impl true
    def horizon_right(container) do
      %Point2D{
        x: container.x + container.width,
        y: vertical_center(container)
      }
    end

    @impl true
    def bottom_right(container) do
      %Point2D{
        x: container.x + container.width,
        y: container.y + container.height
      }
    end

    @impl true
    def bottom_center(container) do
      %Point2D{
        x: horizontal_center(container),
        y: container.y + container.height
      }
    end

    @impl true
    def bottom_left(container) do
      %Point2D{
        x: container.x,
        y: container.y + container.height
      }
    end

    @impl true
    def horizon_left(container) do
      %Point2D{
        x: container.x,
        y: vertical_center(container)
      }
    end

    @impl true
    def top_left(container) do
      %Point2D{
        x: container.x,
        y: container.y + container.height
      }
    end

    @impl true
    def bbox_center(container) do
      0.5 * (bbox_left(container) + bbox_right(container))
    end

    @impl true
    def bbox_horizon(container) do
      0.5 * (bbox_top(container) + bbox_bottom(container))
    end

    @impl true
    def bbox_top(container) do
      container.y
    end

    @impl true
    def bbox_left(container) do
      container.x
    end

    @impl true
    def bbox_right(container) do
      container.x + container.width
    end

    @impl true
    def bbox_bottom(container) do
      container.y + container.height
    end

    @impl true
    def bbox_height(container) do
      bbox_bottom(container) - bbox_top(container)
    end

    @impl true
    def bbox_width(container) do
      bbox_right(container) - bbox_left(container)
    end

    @impl true
    def lengths(container) do
      [container.x, container.y, container.width, container.height]
    end

    @impl true
    def transform_lengths(container, fun) do
      transformed_x = fun.(container.x)
      transformed_y = fun.(container.y)
      transformed_width = fun.(container.width)
      transformed_height = fun.(container.height)

      %{
        container
        | x: transformed_x,
          y: transformed_y,
          width: transformed_width,
          height: transformed_height
      }
    end

    @impl true
    def to_typst(container) do
      stroke =
        if container.stroke do
          # Get the parameters for the stroke
          thickness = Access.get(container.stroke, :thickness, 0.75)
          paint = Access.get(container.stroke, :paint, TypstAst.variable("gray"))
          dash = Access.get(container.stroke, :dash, "dotted")

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
            width: TypstAst.pt(container.width),
            height: TypstAst.pt(container.height)
          )
        )

      TypstAst.place(
        container.x,
        container.y,
        box
      )
    end
  end
end
