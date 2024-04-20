defmodule Quartz.Axis2D do
  alias Quartz.Text
  alias Quartz.Config
  alias Quartz.Canvas
  alias Quartz.Line
  alias Quartz.Sketch
  alias Quartz.Length
  alias Quartz.Scale
  alias Quartz.TickManagers.AutoTickManager
  alias __MODULE__

  require Quartz.Figure, as: Figure

  use Dantzig.Polynomial.Operators
  alias Dantzig.Polynomial

  defstruct name: nil,
            plot_id: nil,
            direction: nil,
            location: nil,
            margin_start: nil,
            margin_end: nil,
            x: nil,
            y: nil,
            size: nil,
            major_ticks_locations: [],
            minor_ticks_labels: [],
            max_value: nil,
            min_value: nil,
            max_value_fixed: false,
            min_value_fixed: false,
            label_inner_padding: Length.pt(8),
            label: nil,
            label_alignment: :center,
            label_location: :center,
            scale: Scale.linear(),
            major_tick_size: Length.pt(7),
            minor_tick_size: Length.pt(5),
            major_tick_manager: AutoTickManager.init(),
            minor_tick_manager: nil

  def new(axis_name, opts \\ []) do
    # Variables which we want to minimize or maximize
    size = Figure.variable("axis_size", min: 0.0)
    margin_start = Figure.variable("axis_margin_start", min: 0.0)
    margin_end = Figure.variable("axis_margin_end", min: 0.0)
    x = Figure.variable("axis_x")
    y = Figure.variable("axis_y")

    Figure.maximize(size)
    Figure.minimize(margin_start)
    Figure.minimize(margin_end)

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
      x: x,
      y: y,
      direction: direction,
      location: location,
      margin_start: margin_start,
      margin_end: margin_end,
      label_inner_padding: label_inner_padding
    }

    axis
  end

  def put_minimum_start_margin(axis, value) do
    Figure.assert(axis.margin_start >= value)
    axis
  end

  def put_minimum_end_margin(axis, value) do
    Figure.assert(axis.margin_end >= value)
    axis
  end

  def put_minimum_margins(axis, value) do
    Figure.assert(axis.margin_end >= value)
    Figure.assert(axis.margin_start >= value)
    axis
  end

  defp tick_size(axis) do
    max(axis.major_tick_size, axis.minor_tick_size)
  end

  def draw(plot, x, y, axis) do
    case axis.location do
      :bottom -> draw_bottom_axis(plot, x, y, axis)
      :left -> draw_left_axis(plot, x, y, axis)
      :top -> draw_top_axis(plot, x, y, axis)
      :right -> draw_right_axis(plot, x, y, axis)
    end
  end

  def draw_bottom_axis(plot, x, y, axis = %Axis2D{location: :bottom}) do
    canvas = Canvas.new(prefix: "bottom_axis_canvas")

    Figure.minimize(canvas.height)

    Figure.assert(canvas.x == x)
    Figure.assert(canvas.y == y)
    Figure.assert(canvas.width == plot.bottom_decorations_area.width)

    Figure.assert(axis.x == x)
    Figure.assert(axis.y == y)

    Figure.assert(
      axis.margin_start + axis.size + axis.margin_end == plot.bottom_decorations_area.width
    )

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

    Figure.assert(axis.x == x)
    Figure.assert(axis.y == y)

    Figure.assert(
      axis.margin_start + axis.size + axis.margin_end == plot.top_decorations_area.width
    )

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

    Figure.minimize(canvas.width)

    Figure.assert(canvas.height == plot.left_decorations_area.height)
    Figure.assert(canvas.y == y)
    Figure.assert(Sketch.bbox_right(canvas) == x)

    Figure.assert(axis.x == x)
    Figure.assert(axis.y == y)

    Figure.assert(
      axis.margin_start + axis.size + axis.margin_end == plot.left_decorations_area.height
    )

    _line = Line.new(x1: x, x2: x, y1: y, y2: y + canvas.height, z_level: 0.0)

    if axis.label do
      x_offset = Polynomial.scale(Polynomial.add(tick_size(axis), axis.label_inner_padding), -1)

      Figure.position_with_location_and_alignment(
        axis.label,
        canvas,
        x_location: :right,
        x_offset: x_offset,
        y_location: axis.label_location,
        y_alignment: axis.label_alignment,
        contains_horizontally?: true
      )
    end

    canvas
  end

  def draw_right_axis(plot, x, y, axis = %Axis2D{location: :right}) do
    canvas = Canvas.new(prefix: "right_axis_canvas")

    Figure.minimize(canvas.width)

    Figure.assert(canvas.height == plot.right_decorations_area.height)
    Figure.assert(canvas.x == x)
    Figure.assert(canvas.y == y)

    Figure.assert(axis.x == x)
    Figure.assert(axis.y == y)

    Figure.assert(
      axis.margin_start + axis.size + axis.margin_end == plot.right_decorations_area.height
    )

    _line = Line.new(x1: x, x2: x, y1: y, y2: y + canvas.height)

    if axis.label do
      x_offset = Polynomial.add(tick_size(axis), axis.label_inner_padding)

      Figure.position_with_location_and_alignment(
        axis.label,
        canvas,
        x_location: :left,
        x_offset: x_offset,
        y_location: axis.label_location,
        y_alignment: axis.label_alignment,
        contains_horizontally?: true
      )
    end

    canvas
  end

  def put_plot_id(%Axis2D{} = axis, plot_id) do
    %{axis | plot_id: plot_id}
  end

  def put_label(%Axis2D{} = axis, label, opts \\ []) do
    # Separate the text-related options from the other options
    {user_given_text_opts, opts} = Keyword.pop(opts, :text, [])

    # Merge the user-given text options with the default options for this figure
    text_opts = Config.get_axis_label_text_attributes(user_given_text_opts)

    # Add the text rotation if given
    text_opts =
      case Keyword.fetch(user_given_text_opts, :rotation) do
        {:ok, rotation} -> [{:rotation, rotation} | text_opts]
        :error -> text_opts
      end

    # Handle the non-text-related options
    alignment =
      case Keyword.get(opts, :alignment) do
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
        :left -> -90
        :right -> 90
        :top -> 0
        :bottom -> 0
      end

    cond do
      is_binary(label) ->
        text = Text.new(label, Keyword.put_new(text_opts, :rotation, rotation))
        %{axis | label: text, label_location: location, label_alignment: alignment}

      # Find out how we should deal with this
      true ->
        %{axis | label: label, label_location: location, label_alignment: alignment}
    end
  end

  def put_scale(%__MODULE__{} = axis, new_scale) do
    %{axis | scale: new_scale}
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

  def maybe_set_limits(%__MODULE__{} = axis, min, max) do
    axis =
      if axis.max_value do
        axis
      else
        %{axis | max_value: max}
      end

    axis =
      if axis.min_value do
        axis
      else
        %{axis | min_value: min}
      end

    axis
  end

  def fix_limits(%__MODULE__{} = axis) do
    %{axis | max_value_fixed: true, min_value_fixed: true}
  end
end
