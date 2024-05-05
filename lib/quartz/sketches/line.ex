defmodule Quartz.Line do
  alias Quartz.Figure
  alias Quartz.Variable
  alias Quartz.SVG
  alias Quartz.Sketch.BBoxBounds
  alias Quartz.Formatter
  require Quartz.KeywordSpec, as: KeywordSpec

  defstruct id: nil,
            x1: nil,
            y1: nil,
            x2: nil,
            y2: nil,
            prefix: nil,
            stroke_paint: nil,
            stroke_cap: nil,
            stroke_thickness: nil,
            stroke_join: nil,
            stroke_dash: nil,
            debug: false,
            debug_properties: nil

  def new(opts \\ []) do
    KeywordSpec.validate!(opts, [
      stroke_join,
      stroke_dash,
      prefix,
      stroke_thickness: 1,
      stroke_paint: "black",
      stroke_cap: "square"
    ])

    # Assign variables (= Dantzig monomials) to the parameters of the line
    x1 = Variable.maybe_variable(opts, :x1, Variable.maybe_with_prefix(prefix, "line_x1"), [])
    y1 = Variable.maybe_variable(opts, :y1, Variable.maybe_with_prefix(prefix, "line_y1"), [])
    x2 = Variable.maybe_variable(opts, :x2, Variable.maybe_with_prefix(prefix, "line_x2"), [])
    y2 = Variable.maybe_variable(opts, :y2, Variable.maybe_with_prefix(prefix, "line_y2"), [])

    # Get the next available ID from the figure
    id = Figure.get_id()

    debug = Figure.debug?()
    debug_properties = nil

    # Create the actual line
    line = %__MODULE__{
      id: id,
      x1: x1,
      y1: y1,
      x2: x2,
      y2: y2,
      prefix: prefix,
      stroke_join: stroke_join,
      stroke_paint: stroke_paint,
      stroke_thickness: stroke_thickness,
      stroke_dash: stroke_dash,
      stroke_cap: stroke_cap,
      debug: debug,
      debug_properties: debug_properties
    }

    # Add the line to the figure
    Figure.add_sketch(id, line)

    # Return the line, with no reference to the figure
    line
  end

  defimpl Quartz.Sketch.Protocol do
    use Dantzig.Polynomial.Operators

    @impl true
    def bbox_bounds(line) do
      %BBoxBounds{
        x_min: line.x1,
        x_max: line.x2,
        y_min: line.y1,
        y_max: line.y2
      }
    end

    @impl true
    def lengths(line) do
      [line.x1, line.y1, line.x2, line.y2]
    end

    @impl true
    def transform_lengths(line, fun) do
      transform_x = fun.(line.x1)
      transform_y = fun.(line.y1)
      transform_x2 = fun.(line.x2)
      transform_y2 = fun.(line.y2)

      %{line | x1: transform_x, y1: transform_y, x2: transform_x2, y2: transform_y2}
    end

    @impl true
    def to_unpositioned_svg(line) do
      to_svg(line)
    end

    @impl true
    def to_svg(line) do
      common_attributes = [
        x1: line.x1,
        y1: line.y1,
        x2: line.x2,
        y2: line.y2,
        stroke: line.stroke_paint,
        "stroke-linejoin": line.stroke_join,
        "stroke-linecap": line.stroke_cap,
        "stroke-opacity": nil
      ]

      if line.debug do
        tooltip_text = [
          "Line [#{line.id}] #{line.prefix} &#13;",
          "&#160;↳&#160;x1 = #{pprint(line.x1)}pt&#13;",
          "&#160;↳&#160;y1 = #{pprint(line.y1)}pt&#13;",
          "&#160;↳&#160;x2 = #{pprint(line.x2)}pt&#13;",
          "&#160;↳&#160;y2 = #{pprint(line.y2)}pt&#13;&#13;"
        ]


        SVG.line(common_attributes, [
          SVG.title([], SVG.escaped_iodata(tooltip_text))
        ])
      else
        SVG.line(common_attributes)
      end
    end

    defp pprint(number) when is_number(number) do
      # Round to two decimal places
      Formatter.rounded_float(number, 2)
    end
  end
end
