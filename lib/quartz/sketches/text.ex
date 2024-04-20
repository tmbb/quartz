defmodule Quartz.TextSpan do
  defstruct id: nil,
            font: nil,
            x: nil,
            y: nil,
            dx: nil,
            dy: nil,
            content: []
end

defmodule Quartz.Text do
  alias Quartz.Variable
  alias Quartz.Figure
  alias Quartz.SVG
  alias Quartz.Sketch.BBoxBounds

  defstruct id: nil,
            x: nil,
            y: nil,
            content: nil,
            font: nil,
            style: nil,
            weight: nil,
            width: nil,
            height: nil,
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
            escape: true

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

    # Get the next available ID from the figure
    id = Figure.get_id()

    all_opts =
      opts
      |> Keyword.put(:content, binary)
      |> Keyword.put(:id, id)
      |> Keyword.put(:x, x)
      |> Keyword.put(:y, y)
      |> Keyword.put(:width, width)
      |> Keyword.put(:height, height)

    # Create the text
    text = struct(__MODULE__, all_opts)
    # Add the text to the current figure
    Figure.add_sketch(id, text)
    Figure.add_unmeasured_item(text)
    # Return the text element, with no reference to the figure
    text
  end

  defimpl Quartz.Sketch.Protocol do
    use Dantzig.Polynomial.Operators
    # alias Quartz.Point2D
    # alias Quartz.Rotations

    # defp horizontal_center(text) do
    #   (text.x + text.width) * 0.5
    # end

    # defp vertical_center(text) do
    #   (text.y + text.height) * 0.5
    # end

    # defp rotate_around_center(p, text) do
    #   Rotations.rotate_point(p, bbox_center(text), text.rotation)
    # end

    @impl true
    def bbox_bounds(text) do
      # Rotations.rotated_rectangle_bounds(
      #   text.x,
      #   text.y,
      #   text.width,
      #   text.height,
      #   text.rotation
      # )

      %BBoxBounds{
        x_min: text.x,
        x_max: text.x + text.width,
        y_min: text.y - text.height,
        y_max: text.y
      }
    end

    @impl true
    def lengths(text) do
      [text.x, text.y, text.width, text.height]
    end

    @impl true
    def transform_lengths(text, fun) do
      transformed_x = fun.(text.x)
      transformed_y = fun.(text.y)
      transformed_width = fun.(text.width)
      transformed_height = fun.(text.height)

      %{
        text
        | x: transformed_x,
          y: transformed_y,
          width: transformed_width,
          height: transformed_height
      }
    end

    @impl true
    def to_svg(text) do
      transform_attrs = []

      SVG.text([
          id: text.id,
          x: text.x,
          y: text.y,
          "text-anchor": "start",
          "alignment-baselines": "baseline",
          "font-family": text.font,
          "font-weight": text.weight,
          "font-style": text.style,
          "font-size": text.size
        ] ++ transform_attrs,
        text.content
      )
    end

    @impl true
    def to_unpositioned_svg(text) do
      # TODO: If we ever implement text stretching, we will
      # have to handle the width better.
      to_svg(%{text | x: 0, y: 0, width: 0, height: 0, rotation: 0})
    end
  end
end
