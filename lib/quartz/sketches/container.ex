defmodule Quartz.Container do
  @moduledoc false

  alias Quartz.Figure
  alias Quartz.Variable
  alias Quartz.Length
  alias Quartz.Color.RGB
  alias Quartz.SVG

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

  defimpl Quartz.Sketch.Protocol do
    use Dantzig.Polynomial.Operators
    alias Quartz.Sketch.BBoxBounds

    @impl true
    def bbox_bounds(container) do
      %BBoxBounds{
        x_min: container.x,
        x_max: container.x + container.width,
        y_min: container.y,
        y_max: container.y + container.height
      }
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
    def to_unpositioned_svg(container) do
      to_svg(container)
    end

    @impl true
    def to_svg(container) do
      if container.stroke do
        thickness = Access.get(container.stroke, :thickness, 0.75)
        paint = Access.get(container.stroke, :paint, "gray")

        SVG.rect(
          id: container.id,
          x: container.x,
          y: container.y,
          width: container.width,
          height: container.height,
          stroke: paint,
          "stroke-width": thickness
        )
      else
        SVG.g([id: container.id], [])
      end
    end
  end
end
