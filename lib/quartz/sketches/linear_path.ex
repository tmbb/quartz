defmodule Quartz.LinearPath do
  alias Quartz.Figure
  alias Quartz.SVG
  alias Quartz.Color.RGB
  alias Quartz.Sketch.BBoxBounds
  require Quartz.KeywordSpec, as: KeywordSpec

  defstruct id: nil,
            prefix: nil,
            points: [],
            closed: false,
            fill: nil,
            stroke_paint: nil,
            stroke_cap: nil,
            stroke_thickness: nil,
            stroke_join: nil,
            stroke_dash: nil,
            debug: nil,
            debug_properties: nil

  def new(opts \\ []) do
    KeywordSpec.validate!(opts, [
      stroke_join,
      stroke_dash,
      prefix: nil,
      points: [],
      closed: false,
      fill: RGB.white(0),
      stroke_thickness: 1,
      stroke_paint: "black",
      stroke_cap: "square"
    ])

    _prefix = prefix

    debug = Figure.debug?()
    debug_properties = nil

    # Get the next available ID from the figure
    id = Figure.get_id()

    # Create the actual line
    path = %__MODULE__{
      id: id,
      prefix: prefix,
      points: points,
      closed: closed,
      fill: fill,
      stroke_join: stroke_join,
      stroke_paint: stroke_paint,
      stroke_thickness: stroke_thickness,
      stroke_dash: stroke_dash,
      stroke_cap: stroke_cap,
      debug: debug,
      debug_properties: debug_properties
    }

    # Add the line to the figure
    Figure.add_sketch(id, path)

    # Return the line, with no reference to the figure
    path
  end

  defimpl Quartz.Sketch.Protocol do
    @impl true
    def bbox_bounds(_path) do
      %BBoxBounds{
        x_min: nil,
        x_max: nil,
        y_min: nil,
        y_max: nil
      }
    end

    @impl true
    def lengths(path) do
      Enum.flat_map(path.points, fn _point = {x, y} -> [x, y] end)
    end

    @impl true
    def transform_lengths(path, fun) do
      transformed_points =
        Enum.map(path.points, fn {x, y} ->
          {fun.(x), fun.(y)}
        end)

      %{path | points: transformed_points}
    end

    @impl true
    def to_unpositioned_svg(path) do
      to_svg(path)
    end

    @impl true
    def to_svg(path) do
      svg_points =
        case path.points do
          [point | points] ->
            {x0, y0} = point

            # Use the Line-to instruction for absolute locations
            next_points = for {x, y} <- points do
              {:L, {x, y}}
            end

            # Use the Move-to instruction for the first point
            path_points = [{:M, {x0, y0}} | next_points]

            if path.closed do
              path_points ++ [:z]
            else
              path_points
            end

          [] ->
            []
        end

      common_attributes = [
        d: svg_points,
        stroke: path.stroke_paint,
        fill: path.fill,
        "stroke-linejoin": path.stroke_join,
        "stroke-linecap": path.stroke_cap
      ]

      if path.debug do
        tooltip_text = [
          "LinearPath [#{path.id}] #{path.prefix} &#13;",
          "&#160;&#160;stroke: #{pprint_color(path.stroke_paint)}&#13;",
          "&#160;&#160;fill: #{pprint_color(path.fill)}&#13;",
        ]

        SVG.path(common_attributes, [
          SVG.title([], SVG.escaped_iodata(tooltip_text)),
        ])
      else
        SVG.path(common_attributes)
      end
    end

    defp pprint_color(color) when is_binary(color), do: color

    defp pprint_color(%RGB{} = color) do
      # Handle all cases for alpha
      alpha = case color.alpha do
        i when is_integer(i) -> (i / 256)
        f when is_float(f) -> f
      end

      "rgba(#{color.red}, #{color.green}, #{color.blue}, #{alpha})"
    end
  end
end
