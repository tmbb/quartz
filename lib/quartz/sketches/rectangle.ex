defmodule Quartz.Rectangle do
  require Quartz.Figure, as: Figure
  alias Quartz.Sketch
  alias Quartz.SVG
  require Quartz.KeywordSpec, as: KeywordSpec

  defstruct id: nil,
            x: nil,
            y: nil,
            prefix: nil,
            width: nil,
            height: nil,
            fill: nil,
            opacity: nil,
            stroke_paint: nil,
            stroke_cap: nil,
            stroke_thickness: nil,
            stroke_join: nil,
            stroke_dash: nil,
            stroke_opacity: nil,
            debug: false,
            z_index: 1.0

  def new(opts \\ []) do
    KeywordSpec.validate!(opts,
      id: Figure.get_id(),
      debug: Figure.debug?(),
      x: nil,
      y: nil,
      height: nil,
      width: nil,
      prefix: nil,
      fill: nil,
      opacity: 1,
      stroke_thickness: nil,
      stroke_paint: nil,
      stroke_cap: nil,
      stroke_join: nil,
      stroke_dash: nil,
      stroke_opacity: nil
    )

    rect_x = Figure.variable("rectangle_x", prefix: prefix)
    rect_y = Figure.variable("rectangle_y", prefix: prefix)
    rect_height = Figure.variable("rectangle_height", min: 0, prefix: prefix)
    rect_width = Figure.variable("rectangle_width", min: 0, prefix: prefix)

    if x, do: Figure.assert(rect_x == x)
    if y, do: Figure.assert(rect_y == y)
    if height, do: Figure.assert(rect_height == height)
    if width, do: Figure.assert(rect_width == width)

    # Create the actual rectangle
    rectangle = %__MODULE__{
      id: id,
      x: rect_x,
      y: rect_y,
      prefix: prefix,
      height: rect_height,
      width: rect_width,
      fill: fill,
      opacity: opacity,
      stroke_join: stroke_join,
      stroke_paint: stroke_paint,
      stroke_thickness: stroke_thickness,
      stroke_dash: stroke_dash,
      stroke_cap: stroke_cap,
      stroke_opacity: stroke_opacity,
      debug: debug
    }

    # Return the rectangle, with no reference to the figure
    rectangle
  end

  def draw_new(opts \\ []) do
    rectangle = new(opts)
    Sketch.draw(rectangle)
  end

  defimpl Quartz.Sketch.Protocol do
    require Dantzig.Polynomial, as: Polynomial
    alias Quartz.Formatter
    alias Quartz.Sketch.BBoxBounds

    @impl true
    def bbox_bounds(rectangle) do
      %BBoxBounds{
        x_min: rectangle.x,
        x_max: Polynomial.algebra(rectangle.x + rectangle.width),
        y_min: rectangle.y,
        y_max: Polynomial.algebra(rectangle.y + rectangle.height),
        baseline: Polynomial.algebra(rectangle.y + rectangle.height)
      }
    end

    @impl true
    def lengths(rectangle) do
      [rectangle.x, rectangle.y, rectangle.width, rectangle.height]
    end

    @impl true
    def transform_lengths(rectangle, fun) do
      transformed_x = fun.(rectangle.x)
      transformed_y = fun.(rectangle.y)
      transformed_width = fun.(rectangle.width)
      transformed_height = fun.(rectangle.height)

      %{
        rectangle
        | x: transformed_x,
          y: transformed_y,
          width: transformed_width,
          height: transformed_height
      }
    end

    @impl true
    def to_unpositioned_svg(rectangle) do
      to_svg(rectangle)
    end

    @impl true
    def to_svg(rectangle) do
      rect_attrs = [
        id: rectangle.id,
        x: rectangle.x,
        y: rectangle.y,
        width: rectangle.width,
        height: rectangle.height,
        fill: rectangle.fill,
        opacity: rectangle.opacity,
        "stroke-width": rectangle.stroke_thickness,
        "stroke-linejoin": rectangle.stroke_join,
        "stroke-linecap": rectangle.stroke_cap,
        stroke_dash: rectangle.stroke_dash,
        stroke_cap: rectangle.stroke_cap,
        stroke_opacity: rectangle.stroke_opacity
      ]

      if rectangle.debug do
        tooltip_text = [
          "rectangle [#{rectangle.id}] #{rectangle.prefix} &#13;",
          "&#160;↳&#160;x = #{Formatter.rounded_float(rectangle.x, 2)}px&#13;",
          "&#160;↳&#160;y = #{Formatter.rounded_float(rectangle.y, 2)}px&#13;",
          "&#160;↳&#160;width = #{Formatter.rounded_float(rectangle.width, 2)}px&#13;",
          "&#160;↳&#160;height = #{Formatter.rounded_float(rectangle.height, 2)}pt"
        ]

        SVG.rect(rect_attrs, [
          SVG.title([], SVG.escaped_iodata(tooltip_text))
        ])
      else
        SVG.rect(rect_attrs, [])
      end
    end

    @impl true
    def assign_measurements_from_resvg_node(rectangle, _resvg_node) do
      rectangle
    end
  end
end
