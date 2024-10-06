defmodule Quartz.Canvas do
  alias Quartz.Figure
  alias Quartz.Variable
  alias Quartz.SVG
  alias Quartz.Canvas.CanvasDebugProperties
  alias Quartz.Config
  alias Quartz.Sketch

  defstruct id: nil,
            x: nil,
            y: nil,
            prefix: nil,
            width: nil,
            height: nil,
            debug: false,
            debug_properties: nil,
            contents: nil

  def new(opts \\ []) do
    prefix = Keyword.get(opts, :prefix, nil)
    # Assign variables (= Dantzig monomials) to the parameters of the canvas
    x = Variable.maybe_variable(opts, :x, Variable.maybe_with_prefix(prefix, "canvas_x"), min: 0)
    y = Variable.maybe_variable(opts, :y, Variable.maybe_with_prefix(prefix, "canvas_y"), min: 0)

    height =
      Variable.maybe_variable(opts, :height, Variable.maybe_with_prefix(prefix, "canvas_height"),
        min: 0
      )

    width =
      Variable.maybe_variable(opts, :width, Variable.maybe_with_prefix(prefix, "canvas_width"),
        min: 0
      )

    # Get the next available ID from the figure
    id = Figure.get_id()

    debug = Figure.debug?()
    debug_properties = if debug, do: Config.get_canvas_debug_properties(), else: nil

    # Create the actual canvas
    canvas = %__MODULE__{
      id: id,
      x: x,
      y: y,
      prefix: prefix,
      height: height,
      width: width,
      debug: debug,
      debug_properties: debug_properties
    }

    # Return the canvas, with no reference to the figure
    canvas
  end

  def draw_new(opts \\ []) do
    canvas = new(opts)
    Sketch.draw(canvas)
    canvas
  end

  defimpl Quartz.Sketch.Protocol do
    require Dantzig.Polynomial, as: Polynomial
    alias Quartz.Formatter
    alias Quartz.Sketch.BBoxBounds

    @impl true
    def bbox_bounds(canvas) do
      %BBoxBounds{
        x_min: canvas.x,
        x_max: Polynomial.algebra(canvas.x + canvas.width),
        y_min: canvas.y,
        y_max: Polynomial.algebra(canvas.y + canvas.height)
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

      debug_properties =
        case canvas.debug_properties do
          %CanvasDebugProperties{} ->
            %{
              canvas.debug_properties
              | stroke_width: fun.(canvas.debug_properties.stroke_width)
            }

          other ->
            other
        end

      %{
        canvas
        | x: transformed_x,
          y: transformed_y,
          width: transformed_width,
          height: transformed_height,
          debug_properties: debug_properties
      }
    end

    @impl true
    def to_unpositioned_svg(canvas) do
      to_svg(canvas)
    end

    @impl true
    def to_svg(canvas) do
      if canvas.debug do
        # Get some extra attributes for our rectangle
        debug_attrs = CanvasDebugProperties.to_svg_attributes(canvas.debug_properties)

        rect_attrs = [
          id: canvas.id,
          x: canvas.x,
          y: canvas.y,
          width: canvas.width,
          height: canvas.height
        ]

        all_attrs = rect_attrs ++ debug_attrs

        tooltip_text = [
          "Canvas [#{canvas.id}] #{canvas.prefix} &#13;",
          "&#160;↳&#160;x = #{Formatter.rounded_float(canvas.x, 2)}pt&#13;",
          "&#160;↳&#160;y = #{Formatter.rounded_float(canvas.y, 2)}pt&#13;",
          "&#160;↳&#160;width = #{Formatter.rounded_float(canvas.width, 2)}pt&#13;",
          "&#160;↳&#160;height = #{Formatter.rounded_float(canvas.height, 2)}pt"
        ]

        SVG.rect(all_attrs, [
          SVG.title([], SVG.escaped_iodata(tooltip_text))
        ])
      else
        SVG.g([id: canvas.id], [])
      end
    end
  end
end
