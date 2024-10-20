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
      debug: Figure.debug?(),
      prefix: nil,
      x: nil,
      y: nil,
      rotation: nil
    )

    unless is_nil(rotation) or is_number(rotation) do
      raise ArgumentError, """
      Text rotation should be a number (float or integer), not a polynomial.
      """
    end

    content = List.wrap(content)

    text_x = Figure.variable("text_x", prefix: prefix)
    text_y = Figure.variable("text_y", prefix: prefix)
    text_width = Figure.variable("text_width", prefix: prefix)
    text_height = Figure.variable("text_height", prefix: prefix)
    text_depth = Figure.variable("text_depth", prefix: prefix)

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
    import Quartz.Operators, only: [algebra: 1]
    import Quartz.Formatter, only: [rounded_length: 1]

    alias Quartz.Rotations
    alias Quartz.Sketch

    @impl true
    def bbox_bounds(%{rotation: angle} = text) when angle in [nil, 0, 0.0] do
      %BBoxBounds{
        x_min: text.x,
        x_max: algebra(text.x + text.width),
        y_min: algebra(text.y - text.height),
        y_max: algebra(text.y + text.depth),
        baseline: text.y
      }
    end

    def bbox_bounds(text) do
      Rotations.rotated_text_bounds(text)
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
                baseline_stroke_width: fun.(text.debug_properties.baseline_stroke_width)
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
      geometry_attrs =
        if text.rotation in [nil, 0, 0.0] do
          # Just add x and y
          [x: text.x, y: text.y]
        else
          # Place the text at zero, and adjust the position using a transformation
          [x: 0, y: 0, transform: rotate_translate(text.x, text.y, text.rotation)]
        end

      # Attributes that are common to "normal mode" and "debug mode"
      common_attributes =
        [
          id: text.id,
          fill: text.fill,
          "font-family": text.font,
          "font-weight": text.weight,
          "font-style": text.style,
          "font-size": text.size,
          "baseline-shift": text.baseline_shift,
          "text-anchor": "start",
          "alignment-baseline": "baseline"
        ] ++ geometry_attrs

      if text.debug do
        tooltip_text = [
          "Text [#{text.id}] #{text.prefix} &#13;",
          "&#160;↳&#160;x = #{debug_pprint(text.x)}px&#13;",
          "&#160;↳&#160;y = #{debug_pprint(text.y)}px&#13;",
          "&#160;↳&#160;rotation = #{debug_pprint(text.y)}°&#13;",
          "&#160;↳&#160;width = #{debug_pprint(text.width)}px&#13;",
          "&#160;↳&#160;height = #{debug_pprint(text.height)}px&#13;",
          "&#160;↳&#160;depth = #{debug_pprint(text.depth)}px&#13;&#13;",
          "&#160;&#160;font: #{text.font}&#13;",
          "&#160;&#160;font-weight: #{text.weight}&#13;",
          "&#160;&#160;font-size: #{text.size}&#13;"
        ]

        height_rect_attrs = debug_height_rect_svg_properties(text)
        depth_rect_attrs = debug_depth_rect_svg_properties(text)
        baseline_attrs = debug_baseline_svg_properties(text)

        text_debug_bbox_components = [
          SVG.rect(height_rect_attrs),
          SVG.rect(depth_rect_attrs),
          SVG.line(baseline_attrs)
        ]

        # SVG text element with extra debug data
        SVG.g(
          [],
          text_debug_bbox_components ++
            [
              SVG.text(
                common_attributes,
                [
                  SVG.title([], SVG.escaped_iodata(tooltip_text))
                  | Enum.map(text.content, &Sketch.to_svg/1)
                ]
              )
            ]
        )
      else
        # SVG text element without extra debug data
        SVG.text(
          common_attributes,
          Enum.map(text.content, &Sketch.to_svg/1)
        )
      end
    end

    defp rotate_translate(x, y, angle) do
      "translate(#{rounded_length(x)}, #{rounded_length(y)}) " <>
        "rotate(#{rounded_length(angle)})"
    end

    @impl true
    def assign_measurements_from_resvg_node(text, resvg_node) do
      height = -resvg_node.y
      # Depths are never negative, even if the character doesn't touch
      # the font's baseline. TODO: does this give us any problems?
      depth = min(resvg_node.height + resvg_node.y, 0.0)
      width = resvg_node.width

      Figure.assert(text.width == width, tags: ["measurement"])
      Figure.assert(text.height == height, tags: ["measurement"])
      Figure.assert(text.depth == depth, tags: ["measurement"])

      %{text | height: height, depth: depth, width: width}
    end

    @impl true
    def to_unpositioned_svg(text) do
      # TODO: If we ever implement text stretching, we will
      # have to handle the width better.
      to_svg(%{
        text
        | x: 0,
          y: 0,
          width: nil,
          height: nil,
          depth: nil,
          rotation: nil,
          debug: false
      })
    end

    defp rotated?(text) do
      text.rotation not in [0, 0.0, nil]
    end

    defp debug_height_rect_svg_properties(text) do
      geom_properties =
        if rotated?(text) do
          [
            x: 0,
            y: -text.height,
            width: text.width,
            height: text.height,
            # Rotate around the bottom-left corner of the rectangle
            transform: rotate_translate(text.x, text.y, text.rotation)
          ]
        else
          [
            x: text.x,
            y: text.y - text.height,
            width: text.width,
            height: text.height
          ]
        end

      style_properties = TextDebugProperties.to_height_svg_attributes(text.debug_properties)

      geom_properties ++ style_properties
    end

    defp debug_depth_rect_svg_properties(text) do
      geom_properties =
        if rotated?(text) do
          [
            x: 0,
            y: 0,
            width: text.width,
            height: text.depth,
            # Rotate around the bottom-left corner of the rectangle
            transform: rotate_translate(text.x, text.y, text.rotation)
          ]
        else
          [
            x: text.x,
            y: text.y,
            width: text.width,
            height: text.depth
          ]
        end

      style_properties = TextDebugProperties.to_depth_svg_attributes(text.debug_properties)

      geom_properties ++ style_properties
    end

    defp debug_baseline_svg_properties(text) do
      geom_properties =
        if rotated?(text) do
          [
            x1: 0,
            y1: 0,
            x2: text.width,
            y2: 0,
            # Rotate around the bottom-left corner of the rectangle
            transform: rotate_translate(text.x, text.y, text.rotation)
          ]
        else
          [
            x1: text.x,
            y1: text.y,
            x2: text.x + text.width,
            y2: text.y
          ]
        end

      style_properties = TextDebugProperties.to_baseline_svg_attributes(text.debug_properties)

      geom_properties ++ style_properties
    end

    defp debug_pprint(number) do
      # Round to two decimal places
      Formatter.rounded_length(number, 2)
    end
  end
end
