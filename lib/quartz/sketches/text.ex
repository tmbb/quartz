defmodule Quartz.TextSpan do
  @moduledoc false

  defstruct id: nil,
            font: nil,
            x: nil,
            y: nil,
            dx: nil,
            dy: nil,
            content: []
end

defmodule Quartz.Text do
  @moduledoc """
  Text element.
  """

  alias Quartz.Variable
  alias Quartz.Figure
  alias Quartz.SVG
  alias Quartz.Sketch.BBoxBounds
  alias Quartz.Formatter

  @type t() :: %__MODULE__{}

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
            prefix: nil,
            debug: false,
            debug_properties: nil

  @doc """
  Create a text element.
  """
  def new(binary, opts \\ []) do
    prefix = Keyword.get(opts, :prefix, nil)
    # Assign variables (= Dantzig monomials) to the parameters of the canvas
    x = Variable.maybe_variable(opts, :x, Variable.maybe_with_prefix(prefix, "text_x"), [])
    y = Variable.maybe_variable(opts, :y, Variable.maybe_with_prefix(prefix, "text_y"), [])

    height =
      Variable.maybe_variable(opts, :height, Variable.maybe_with_prefix(prefix, "text_height"),
        min: 0
      )

    width =
      Variable.maybe_variable(opts, :width, Variable.maybe_with_prefix(prefix, "text_width"),
        min: 0
      )

    depths =
      Variable.maybe_variable(opts, :depth, Variable.maybe_with_prefix(prefix, "text_depth"),
        min: 0
      )

    # Get the next available ID from the figure
    id = Figure.get_id()

    debug = Figure.debug?()
    debug_properties = nil

    all_opts =
      opts
      |> Keyword.put(:content, binary)
      |> Keyword.put(:id, id)
      |> Keyword.put(:x, x)
      |> Keyword.put(:y, y)
      |> Keyword.put(:width, width)
      |> Keyword.put(:height, height)
      |> Keyword.put(:depth, depths)
      |> Keyword.put(:debug, debug)
      |> Keyword.put(:debug_properties, debug_properties)

    # Create the text
    text = struct(__MODULE__, all_opts)
    # Add the text to the current figure
    Figure.add_sketch(id, text)
    Figure.add_unmeasured_item(text)

    # Return the text element, with no reference to the figure
    text
  end

  defimpl Quartz.Sketch.Protocol do
    require Dantzig.Polynomial, as: Polynomial
    use Dantzig.Polynomial.Operators

    @impl true
    def bbox_bounds(text) do
      %BBoxBounds{
        x_min: text.x,
        x_max: Polynomial.algebra(text.x + text.width),
        y_min: Polynomial.algebra(text.y - text.height),
        y_max: Polynomial.algebra(text.y + text.depth)
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

      %{
        text
        | x: transformed_x,
          y: transformed_y,
          width: transformed_width,
          height: transformed_height,
          depth: transformed_depth
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
          "text-anchor": "start",
          "alignment-baseline": "baseline"
        ] ++ transform_attrs

      if text.debug do
        tooltip_text = [
          "Text [#{text.id}] #{text.prefix} &#13;",
          "&#160;↳&#160;x = #{pprint(text.x)}pt&#13;",
          "&#160;↳&#160;y = #{pprint(text.y)}pt&#13;",
          "&#160;↳&#160;width = #{pprint(text.width)}pt&#13;",
          "&#160;↳&#160;height = #{pprint(text.height)}pt&#13;",
          "&#160;↳&#160;depth = #{pprint(text.depth)}pt&#13;&#13;",
          "&#160;&#160;font: #{text.font}&#13;",
          "&#160;&#160;font-weight: #{text.weight}&#13;",
          "&#160;&#160;font-size: #{text.size}&#13;"
        ]

        # SVG text element with extra debug data
        SVG.text(common_attributes, [
          SVG.title([], SVG.escaped_iodata(tooltip_text)),
          text.content
        ])
      else
        # SVG text element without extra debug data
        SVG.text(common_attributes, text.content)
      end
    end

    defp pprint(number) when is_number(number) do
      # Round to two decimal places
      Formatter.rounded_float(number, 2)
    end

    @impl true
    def to_unpositioned_svg(text) do
      # TODO: If we ever implement text stretching, we will
      # have to handle the width better.
      to_svg(%{text | x: 0, y: 0, width: 0, height: 0, depth: 0, rotation: 0, debug: false})
    end
  end
end
