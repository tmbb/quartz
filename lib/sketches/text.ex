defmodule Quartz.Text do
  alias Quartz.Typst
  alias Quartz.Variable
  alias Quartz.Figure

  defstruct id: nil,
            font: nil,
            fallback: nil,
            style: nil,
            weight: nil,
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
            x: nil,
            y: nil,
            width: nil,
            height: nil,
            rotation: 0,
            content: nil

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
    # Return the canvas, with no reference to the figure
    text
  end

  defimpl Quartz.Sketch do
    use Dantzig.Polynomial.Operators
    alias Quartz.Point2D
    alias Quartz.Rotations

    defp horizontal_center(text) do
      (text.x + text.width) * 0.5
    end

    defp vertical_center(text) do
      (text.y + text.height) * 0.5
    end

    defp rotate_around_center(p, text) do
      Rotations.rotate_point(p, bbox_center(text), text.rotation)
    end

    def bbox_bounds(text) do
      Rotations.rotated_rectangle_bounds(
        text.x,
        text.y,
        text.width,
        text.height,
        text.rotation
      )
    end

    @impl true
    def top_center(text) do
      p = %Point2D{x: horizontal_center(text), y: text.y}
      rotate_around_center(p, text)
    end

    @impl true
    def top_right(text) do
      p = %Point2D{x: text.x + text.width, y: text.y}
      rotate_around_center(p, text)
    end

    @impl true
    def horizon_right(text) do
      p = %Point2D{x: text.x + text.width, y: vertical_center(text)}
      rotate_around_center(p, text)
    end

    @impl true
    def bottom_right(text) do
      p = %Point2D{x: text.x + text.width, y: text.y + text.height}
      rotate_around_center(p, text)
    end

    @impl true
    def bottom_center(text) do
      p = %Point2D{x: horizontal_center(text), y: text.y + text.height}
      rotate_around_center(p, text)
    end

    @impl true
    def bottom_left(text) do
      p = %Point2D{x: text.x, y: text.y + text.height}
      rotate_around_center(p, text)
    end

    @impl true
    def horizon_left(text) do
      p = %Point2D{x: text.x, y: vertical_center(text)}
      rotate_around_center(p, text)
    end

    @impl true
    def top_left(text) do
      p = %Point2D{x: text.x, y: text.y + text.height}
      rotate_around_center(p, text)
    end

    @impl true
    def bbox_center(text) do
      0.5 * (bbox_left(text) + bbox_right(text))
    end

    @impl true
    def bbox_horizon(text) do
      (0.5 * (bbox_top(text) + bbox_bottom(text)))
    end

    @impl true
    def bbox_top(text) do
      {{_x_min, _x_max}, {y_min, _y_max}} = bbox_bounds(text)
      y_min
    end

    @impl true
    def bbox_left(text) do
      {{x_min, _x_max}, {_y_min, _y_max}} = bbox_bounds(text)
      x_min
    end

    @impl true
    def bbox_right(text) do
      {{_x_min, x_max}, {_y_min, _y_max}} = bbox_bounds(text)
      x_max
    end

    @impl true
    def bbox_bottom(text) do
      {{_x_min, _x_max}, {_y_min, y_max}} = bbox_bounds(text)
      y_max
    end

    @impl true
    def bbox_height(text) do
      bbox_bottom(text) - bbox_top(text)
    end

    @impl true
    def bbox_width(text) do
      bbox_right(text) - bbox_left(text)
    end

    @impl true
    def lengths(text) do
      [text.x, text.y, text.width, text.height]
    end

    @impl true
    def solve(text) do
      solved_x = Figure.solve!(text.x)
      solved_y = Figure.solve!(text.y)
      solved_width = Figure.solve!(text.width)
      solved_height = Figure.solve!(text.height)

      %{text | x: solved_x, y: solved_y, width: solved_width, height: solved_height}
    end

    alias Quartz.Typst.TypstValue
    alias Quartz.Typst.TypstAst

    @impl true
    def to_typst(text) do
      unrotated_typst_text = TypstValue.to_typst(text)

      typst_text =
        case text.rotation do
          zero when zero in [0, 0.0] ->
            unrotated_typst_text

          rotation ->
            TypstAst.function_call(
              TypstAst.variable("rotate"),
              [TypstAst.raw("#{-rotation}deg"), unrotated_typst_text]
            )
        end

      TypstAst.place(
        text.x,
        text.y,
        typst_text
      )
    end
  end

  defimpl Quartz.Typst.TypstValue do
    alias Quartz.Typst.TypstAst
    alias Quartz.Typst

    defp to_typst_helper(text, keys_to_drop) do
      content =
        case text.escape do
          true ->
            # Return the text as a string, which is the Typst way
            # of inserting escaped content
            text.content

          false ->
            # Return raw content
            TypstAst.raw("[#{text.content}]")
        end

      named_arguments =
        text
        # Drop :content because it will be given as the last argument
        |> Map.drop([:__struct__, :id, :content, :escape, :rotation])
        # Drop some extra keys
        |> Map.drop(keys_to_drop)
        # Add units to unitless values
        |> Map.update!(:size, fn value -> TypstAst.pt(value) end)
        # Remove the keys without values (the default value will be picked by Typst)
        |> Enum.reject(fn {_key, value} -> value == nil end)
        # Typst uses hyphens instead of underscores; we must conform to that notation
        |> Typst.underscore_in_keys_to_hyphen()
        # Finally, convert the list into proper named arguments
        |> TypstAst.named_arguments_from_proplist()

      {content, named_arguments}
    end

    @impl true
    def to_unpositioned_typst(text) do
      {content, named_arguments} = to_typst_helper(text, [:x, :y, :width, :height])

      TypstAst.function_call(
        TypstAst.variable("text"),
        named_arguments ++ [content]
      )
    end

    @impl true
    def to_typst(text) do
      {content, named_arguments} = to_typst_helper(text, [:x, :y, :width, :height])

      TypstAst.function_call(
        TypstAst.variable("text"),
        named_arguments ++ [content]
      )
    end
  end
end
