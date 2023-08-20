defmodule Quartz.Axis2D do
  alias Quartz.Text
  alias Quartz.Config
  alias Quartz.Typst.TypstAst
  alias Quartz.Canvas
  alias Quartz.Line
  alias Quartz.Sketch
  alias Quartz.Length
  alias __MODULE__

  require Quartz.Figure, as: Figure

  use Dantzig.Polynomial.Operators
  alias Dantzig.Polynomial

  defstruct name: nil,
            plot_id: nil,
            direction: nil,
            location: nil,
            margin_start: 0,
            margin_end: 0,
            size: nil,
            major_ticks: [],
            minor_ticks: [],
            max_value: nil,
            min_value: nil,
            max_value_fixed: false,
            min_value_fixed: false,
            label_inner_padding: Length.pt(8),
            label: nil,
            label_alignment: :center,
            label_location: :center,
            scale: nil,
            major_tick_size: Length.pt(7),
            minor_tick_size: Length.pt(5),
            major_tick_manager: nil,
            minor_tick_manager: nil

  defp maybe_variable(struct_opts, key, variable_name, variable_opts) do
    case Keyword.fetch(struct_opts, key) do
      {:ok, variable} ->
        variable

      :error ->
        Figure.variable(variable_name, variable_opts)
    end
  end

  defp tick_size(axis) do
    max(axis.major_tick_size, axis.minor_tick_size)
  end

  def draw_bottom_axis(plot, x, y, axis = %Axis2D{location: :bottom}) do
    canvas = Canvas.new(prefix: "bottom_axis_canvas")

    Figure.minimize(canvas.height)

    Figure.assert(canvas.x == x)
    Figure.assert(canvas.y == y)
    Figure.assert(canvas.width == plot.bottom_decorations_area.width)

    _line = Line.new(x1: x, x2: x + canvas.width, y1: y, y2: y)

    if axis.label do
      y_offset = Polynomial.add(tick_size(axis), axis.label_inner_padding)

      Figure.position_with_location_and_alignment(
        axis.label,
        canvas,
        x_location: axis.label_location,
        x_alignment: axis.label_alignment,
        y_location: :top,
        y_offset: y_offset,
        contains_vertically?: true
      )
    end

    canvas
  end

  def draw_top_axis(plot, x, y, axis = %Axis2D{location: :top}) do
    canvas = Canvas.new(prefix: "top_axis_canvas")

    Figure.minimize(canvas.height)

    Figure.assert(canvas.width == plot.top_decorations_area.width)
    Figure.assert(canvas.x == x)
    Figure.assert(Sketch.bbox_bottom(canvas) == y)

    # IO.inspect(axis.label, label: "axis.label")
    # IO.inspect(axis.label_alignment, label: "axis.label_alignment")
    # IO.inspect(axis.label_location, label: "axis.label_location")

    _line = Line.new(x1: x, x2: x + canvas.width, y1: y, y2: y)

    if axis.label do
      y_offset =
        tick_size(axis)
        |> Polynomial.add(axis.label_inner_padding)
        |> Polynomial.scale(-1)


      Figure.position_with_location_and_alignment(
        axis.label,
        canvas,
        x_location: axis.label_location,
        x_alignment: axis.label_alignment,
        y_location: :bottom,
        y_offset: y_offset,
        contains_vertically?: true
      )
    end

    canvas
  end

  def draw_left_axis(plot, x, y, axis = %Axis2D{location: :left}) do
    canvas = Canvas.new(prefix: "left_axis_canvas")

    Figure.assert(canvas.height == plot.left_decorations_area.height)
    Figure.assert(canvas.y == y)
    Figure.assert(Sketch.bbox_right(canvas) == x)

    Figure.minimize(canvas.width)

    _line = Line.new(x1: x, x2: x, y1: y, y2: y + canvas.height)

    if axis.label do
      x_offset = Polynomial.scale(Polynomial.add(tick_size(axis), axis.label_inner_padding), -1)

      Figure.position_with_location_and_alignment(
        axis.label,
        canvas,
        x_location: :right,
        y_location: axis.label_location,
        y_alignment: axis.label_alignment,
        x_offset: x_offset,
        contains_horizontally?: true
      )
    end

    canvas
  end

  def draw_right_axis(plot, x, y, axis = %Axis2D{location: :right}) do
    canvas = Canvas.new(prefix: "right_axis_canvas")

    Figure.assert(canvas.height == plot.right_decorations_area.height)
    Figure.assert(canvas.x == x)
    Figure.assert(Sketch.bbox_left(canvas) == x)

    Figure.minimize(canvas.width)

    _line = Line.new(x1: x, x2: x, y1: y, y2: y + canvas.height)

    if axis.label do
      x_offset = Polynomial.add(tick_size(axis), axis.label_inner_padding)

      Figure.position_with_location_and_alignment(
        axis.label,
        canvas,
        x_location: :left,
        y_location: axis.label_location,
        y_alignment: axis.label_alignment,
        x_offset: x_offset,
        contains_horizontally?: true
      )
    end

    canvas
  end

  # defp maybe_with_prefix(nil, variable_name), do: variable_name
  # defp maybe_with_prefix(prefix, variable_name), do: "#{prefix}_#{variable_name}"

  def new(axis_name, opts \\ []) do
    size = maybe_variable(opts, :size, "axis_size", [])
    margin_start = maybe_variable(opts, :margin_start, "axis_size", [])
    margin_end = maybe_variable(opts, :size, "axis_size", [])
    label_inner_padding = Keyword.get(opts, :label_inner_padding, Length.pt(8))

    location = Keyword.fetch!(opts, :location)

    direction =
      case Keyword.fetch(opts, :direction) do
        {:ok, direction} ->
          direction

        :error ->
          case location do
            horizontal when horizontal in [:top, :bottom] -> :left_to_right
            vertical when vertical in [:left, :right] -> :bottom_to_top
          end
      end

    axis = %__MODULE__{
      name: axis_name,
      size: size,
      direction: direction,
      location: location,
      margin_start: margin_start,
      margin_end: margin_end,
      label_inner_padding: label_inner_padding
    }

    axis
  end

  def put_plot_id(%Axis2D{} = axis, plot_id) do
    %{axis | plot_id: plot_id}
  end

  def put_label(%Axis2D{} = axis, label, opts \\ []) do
    # Separate the text-related options from the other options
    {user_given_text_opts, opts} = Keyword.pop(opts, :text, [])

    # Merge the user-given text options with the default options for this figure
    text_opts = Config.get_axis_label_text_attributes(user_given_text_opts)

    # Handle the non-text-related options
    alignment = case Keyword.get(opts, :alignment) do
      nil ->
        case axis.location do
          :left -> :horizon
          :top -> :center
          :right -> :horizon
          :bottom -> :center
        end

      other ->
        other
    end

    location = Keyword.get(opts, :location, alignment)

    rotation =
      case axis.location do
        :left -> 0
        :right -> 0
        :top -> 0
        :bottom -> 0
      end

    cond do
      is_binary(label) ->
        text = Text.new(label, Keyword.put_new(text_opts, :rotation, rotation))
        %{axis | label: text, label_location: location, label_alignment: alignment}

      # Find out how we should deal with this
      true ->
        %TypstAst{} = label
        %{axis | label: label, label_location: location, label_alignment: alignment}
    end
  end

  def set_max_value(%__MODULE__{} = axis, new_max_value) do
    if axis.max_value_fixed do
      raise RuntimeError, "maximum value of axis is fixed"
    else
      %{axis | max_value: new_max_value}
    end
  end

  def set_min_value(%__MODULE__{} = axis, new_min_value) do
    if axis.max_value_fixed do
      raise RuntimeError, "minimum value of axis is fixed"
    else
      %{axis | min_value: new_min_value}
    end
  end
end
