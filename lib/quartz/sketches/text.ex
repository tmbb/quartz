defmodule Quartz.Text do
  @moduledoc """
  Text element.
  """

  alias Quartz.Sketch
  alias Quartz.Config
  alias Quartz.Figure
  alias Quartz.SVG
  alias Quartz.Sketch.BBoxBounds
  alias Quartz.Formatter
  alias Quartz.Text.TextDebugProperties
  alias Quartz.Text.Tspan

  require Quartz.Figure, as: Figure
  require Quartz.KeywordSpec, as: KeywordSpec

  @type t() :: %__MODULE__{}

  @type text() :: t() | binary()

  defstruct id: nil,
            x: nil,
            y: nil,
            content: nil,
            font: nil,
            style: nil,
            weight: nil,
            width: nil,
            height: nil,
            depth: nil,
            rotation: 0,
            fallback: nil,
            stretch: nil,
            size: nil,
            fill: nil,
            tracking: nil,
            spacing: nil,
            baseline: nil,
            overhang: nil,
            top_edge: nil,
            bottom_edge: nil,
            lang: nil,
            region: nil,
            dir: nil,
            hyphenate: nil,
            kerning: nil,
            alternates: nil,
            stylistic_set: nil,
            ligatures: nil,
            discretionary_ligatures: nil,
            historical_ligatures: nil,
            number_type: nil,
            number_width: nil,
            slashed_zero: nil,
            fractions: nil,
            features: nil,
            escape: true,
            baseline_shift: nil,
            prefix: nil,
            debug: false,
            debug_properties: nil,
            z_index: 1.0

  @doc """
  Create a text element.
  """
  def new(content, opts \\ []) do
    KeywordSpec.validate!(opts,
      id: Figure.get_id(),
      prefix: nil,
      x: nil,
      y: nil,
      debug: Figure.debug?()
    )

    content = List.wrap(content)

    text_x = Figure.variable("text_x", prefix: prefix)
    text_y = Figure.variable("text_y", prefix: prefix)
    text_width = Figure.variable("text_width", min: 0, prefix: prefix)
    text_height = Figure.variable("text_height", min: 0, prefix: prefix)
    text_depth = Figure.variable("text_depth", min: 0, prefix: prefix)

    if x, do: Figure.assert(text_x == x)
    if y, do: Figure.assert(text_y == y)

    # Get the next available ID from the figure
    debug_properties = if debug, do: Config.get_text_debug_properties(), else: nil

    all_opts =
      opts
      |> Keyword.put(:content, content)
      |> Keyword.put(:id, id)
      |> Keyword.put(:x, text_x)
      |> Keyword.put(:y, text_y)
      |> Keyword.put(:width, text_width)
      |> Keyword.put(:height, text_height)
      |> Keyword.put(:depth, text_depth)
      |> Keyword.put(:debug, debug)
      |> Keyword.put(:debug_properties, debug_properties)

    # Create the text
    text = struct(__MODULE__, all_opts)

    # Return the text element, with no reference to the figure
    text
  end

  def draw_new(content, opts \\ []) do
    text = new(content, opts)
    Sketch.draw(text)
    text
  end

  def tspan(content, attrs \\ []) do
    Tspan.new(content, attrs)
  end

  def sub(content, attrs \\ []) do
    new_attrs =
      attrs
      |> Keyword.put(:size, "65%")
      |> Keyword.put(:baseline_shift, "-0.50em")

    Tspan.new(content, new_attrs)
  end

  def sup(content, attrs \\ []) do
    new_attrs =
      attrs
      |> Keyword.put(:size, "65%")
      |> Keyword.put(:dx, "0.1em")
      |> Keyword.put(:baseline_shift, "0.65em")

    Tspan.new(content, new_attrs)
  end

  defimpl Quartz.Sketch.Protocol do
    require Dantzig.Polynomial, as: Polynomial
    alias Quartz.Sketch

    @impl true
    def bbox_bounds(text) do
      %BBoxBounds{
        x_min: text.x,
        x_max: Polynomial.algebra(text.x + text.width),
        y_min: Polynomial.algebra(text.y - text.height),
        y_max: Polynomial.algebra(text.y + text.depth),
        baseline: text.y
      }
    end

    @impl true
    def lengths(text) do
      [text.x, text.y, text.width, text.height, text.depth]
    end

    @impl true
    def transform_lengths(text, fun) do
      transformed_x = fun.(text.x)
      transformed_y = fun.(text.y)
      transformed_width = fun.(text.width)
      transformed_height = fun.(text.height)
      transformed_depth = fun.(text.depth)

      debug_properties =
        case text.debug_properties do
          %TextDebugProperties{} ->
            %{
              text.debug_properties
              | height_stroke_width: fun.(text.debug_properties.height_stroke_width),
                depth_stroke_width: fun.(text.debug_properties.depth_stroke_width),
                baseline_stroke_width: fun.(text.debug_properties.baseline_stroke_width),
            }

          other ->
            other
        end

      %{
        text
        | x: transformed_x,
          y: transformed_y,
          width: transformed_width,
          height: transformed_height,
          depth: transformed_depth,
          debug_properties: debug_properties
      }
    end

    @impl true
    def to_svg(text) do
      transform_attrs = []

      # Attributes that are common to "normal mode" and "debug mode"
      common_attributes =
        [
          id: text.id,
          x: text.x,
          y: text.y,
          fill: text.fill,
          "font-family": text.font,
          "font-weight": text.weight,
          "font-style": text.style,
          "font-size": text.size,
          "baseline-shift": text.baseline_shift,
          "text-anchor": "start",
          "alignment-baseline": "baseline"
        ] ++ transform_attrs

      if text.debug do
        tooltip_text = [
          "Text [#{text.id}] #{text.prefix} &#13;",
          "&#160;↳&#160;x = #{pprint(text.x)}px&#13;",
          "&#160;↳&#160;y = #{pprint(text.y)}px&#13;",
          "&#160;↳&#160;width = #{pprint(text.width)}px&#13;",
          "&#160;↳&#160;height = #{pprint(text.height)}px&#13;",
          "&#160;↳&#160;depth = #{pprint(text.depth)}px&#13;&#13;",
          "&#160;&#160;font: #{text.font}&#13;",
          "&#160;&#160;font-weight: #{text.weight}&#13;",
          "&#160;&#160;font-size: #{text.size}&#13;"
        ]

        height_rect_attrs = debug_height_rect_svg_properties(text)
        depth_rect_attrs = debug_depth_rect_svg_properties(text)
        baseline_attrs = debug_baseline_svg_properties(text)

        # SVG text element with extra debug data
        SVG.g([], [
          SVG.rect(height_rect_attrs),
          SVG.rect(depth_rect_attrs),
          SVG.line(baseline_attrs),
          SVG.text(common_attributes,
            [
              SVG.title([], SVG.escaped_iodata(tooltip_text)) |
              Enum.map(text.content, &Sketch.to_svg/1)
            ]
          )
        ])
      else
        # SVG text element without extra debug data
        SVG.text(
          common_attributes,
          Enum.map(text.content, &Sketch.to_svg/1)
        )
      end
    end

    @impl true
    def assign_measurements_from_resvg_node(text, resvg_node) do
      height = - resvg_node.y
      _depth = resvg_node.height + resvg_node.y
      width = resvg_node.width

      Figure.assert(text.width == width)
      Figure.assert(text.height == height)
      Figure.assert(text.depth == 0.0)

      text
    end

    @impl true
    def to_unpositioned_svg(text) do
      # TODO: If we ever implement text stretching, we will
      # have to handle the width better.
      to_svg(%{text |
                x: 0, y: 0, width: nil, height: nil, depth: nil,
                rotation: nil, debug: false})
    end

    defp debug_height_rect_svg_properties(text) do
      geom_properties = [
        x: text.x,
        y: text.y - text.height,
        width: text.width,
        height: text.height
      ]

      style_properties = TextDebugProperties.to_height_svg_attributes(text.debug_properties)

      geom_properties ++ style_properties
    end

    defp debug_depth_rect_svg_properties(text) do
      geom_properties = [
        x: text.x,
        y: text.y,
        width: text.width,
        height: text.depth
      ]

      style_properties = TextDebugProperties.to_depth_svg_attributes(text.debug_properties)

      geom_properties ++ style_properties
    end

    defp debug_baseline_svg_properties(text) do
      geom_properties = [
        x1: text.x,
        y1: text.y,
        x2: text.x + text.width,
        y2: text.y
      ]

      style_properties = TextDebugProperties.to_baseline_svg_attributes(text.debug_properties)

      geom_properties ++ style_properties
    end

    defp pprint(number) when is_number(number) do
      # Round to two decimal places
      Formatter.rounded_float(number, 2)
    end
  end
end
