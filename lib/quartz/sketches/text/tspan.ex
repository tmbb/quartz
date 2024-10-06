defmodule Quartz.Text.Tspan do
  @moduledoc false

  alias Quartz.Config
  alias Quartz.Figure
  alias Quartz.SVG
  alias Quartz.Sketch.BBoxBounds
  # alias Quartz.Formatter
  alias Quartz.Text.TextDebugProperties

  @type t() :: %__MODULE__{}

  @type tspan() :: t() | binary()

  defstruct id: nil,
            dx: nil,
            dy: nil,
            height: nil,
            width: nil,
            depth: nil,
            content: nil,
            font: nil,
            style: nil,
            weight: nil,
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
            debug_properties: nil

  @doc """
  Create a tspan element.
  """
  def new(content, opts \\ []) do
    _prefix = Keyword.get(opts, :prefix, nil)

    content = List.wrap(content)
    # Get the next available ID from the figure
    id = Figure.get_id()

    debug = Figure.debug?()
    debug_properties = if debug, do: Config.get_text_debug_properties(), else: nil

    all_opts =
      opts
      |> Keyword.put(:content, content)
      |> Keyword.put(:id, id)
      |> Keyword.put(:debug, debug)
      |> Keyword.put(:debug_properties, debug_properties)

    # No need to add or measure the tspan, it's always inside a tspan
    # Return the tspan element, with no reference to the figure
    struct(__MODULE__, all_opts)
  end

  defimpl Quartz.Sketch.Protocol do
    alias Quartz.Sketch

    @impl true
    def bbox_bounds(_tspan) do
      %BBoxBounds{
        x_min: 0,
        x_max: 0,
        y_min: 0,
        y_max: 0
      }
    end

    @impl true
    def lengths(tspan) do
      [tspan.debug_properties.stroke_width]
    end

    @impl true
    def transform_lengths(tspan, fun) do
      debug_properties =
        case tspan.debug_properties do
          %TextDebugProperties{} ->
            %{
              tspan.debug_properties
              | stroke_width: fun.(tspan.debug_properties.stroke_width)
            }

          other ->
            other
        end

      %{tspan | debug_properties: debug_properties}
    end

    @impl true
    def to_svg(tspan) do
      transform_attrs = []

      # Attributes that are common to "normal mode" and "debug mode"
      common_attributes =
        [
          id: tspan.id,
          fill: tspan.fill,
          dx: tspan.dx,
          dy: tspan.dy,
          "font-family": tspan.font,
          "font-weight": tspan.weight,
          "font-style": tspan.style,
          "font-size": tspan.size,
          "baseline-shift": tspan.baseline_shift,
          "text-anchor": "start",
          "alignment-baseline": "baseline"
        ] ++ transform_attrs

      SVG.tspan(
        common_attributes,
        Enum.map(tspan.content, &Sketch.to_svg/1)
      )
    end

    @impl true
    def to_unpositioned_svg(tspan) do
      # TODO: If we ever implement tspan stretching, we will
      # have to handle the width better.
      to_svg(%{tspan | debug: false})
    end

    # defp pprint(number) when is_number(number) do
    #   # Round to two decimal places
    #   Formatter.rounded_float(number, 2)
    # end

    # defp debug_rect_svg_properties(tspan) do
    #   geom_properties = [
    #     x: tspan.x,
    #     y: tspan.y - tspan.height,
    #     width: tspan.width,
    #     height: tspan.height
    #   ]

    #   style_properties = TextDebugProperties.to_svg_attributes(tspan.debug_properties)

    #   geom_properties ++ style_properties
    # end
  end
end
