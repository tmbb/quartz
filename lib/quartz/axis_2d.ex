defmodule Quartz.Axis2D do
  alias Quartz.Text
  alias Quartz.Config
  alias Quartz.Canvas
  alias Quartz.Line
  alias Quartz.Sketch
  alias Quartz.Length
  alias Quartz.Scale
  alias Quartz.AxisData
  alias Quartz.TickManagers.AutoTickManager
  alias __MODULE__

  require Quartz.Figure, as: Figure

  use Dantzig.Polynomial.Operators

  require Dantzig.Polynomial, as: Polynomial

  defstruct name: nil,
            plot_id: nil,
            direction: nil,
            location: nil,
            margin_start: nil,
            margin_end: nil,
            x: nil,
            y: nil,
            size: nil,
            style: [],
            max_value: nil,
            min_value: nil,
            max_value_fixed: false,
            min_value_fixed: false,
            label_inner_padding: Length.pt(8),
            label: nil,
            label_alignment: :center,
            label_location: :center,
            scale: Scale.linear(),
            major_tick_locations: nil,
            major_tick_size: Length.pt(4),
            major_tick_manager: AutoTickManager.init(),
            major_tick_labels: nil,
            major_tick_label_inner_padding: Length.pt(3),
            minor_tick_locations: nil,
            minor_tick_size: Length.pt(2),
            minor_tick_manager: nil,
            minor_tick_labels: nil,
            major_tick_labels_style: []

  def new(axis_name, opts \\ []) do
    # Variables which we want to minimize or maximize
    size = Figure.variable("#{axis_name}_axis_size", min: 0.0)
    margin_start = Figure.variable("#{axis_name}_axis_margin_start", min: 0.0)
    margin_end = Figure.variable("#{axis_name}_axis_margin_end", min: 0.0)
    x = Figure.variable("#{axis_name}_axis_x")
    y = Figure.variable("#{axis_name}_axis_y")

    Figure.maximize(size)
    Figure.minimize(margin_start, level: 20)
    Figure.minimize(margin_end, level: 20)

    label_inner_padding = Keyword.get(opts, :label_inner_padding, Length.pt(8))

    location = Keyword.fetch!(opts, :location)

    label_location =
      case location do
        :top -> :center
        :bottom -> :center
        :left -> :horizon
        :right -> :horizon
      end

    label_alignment =
      case location do
        :top -> :center
        :bottom -> :center
        :left -> :horizon
        :right -> :horizon
      end

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
      label_location: label_location,
      label_alignment: label_alignment,
      label_inner_padding: label_inner_padding
    }

    axis
  end

  def put_major_tick_labels_style(axis, style) do
    style_as_kw_list = Enum.into(style, [])

    unless Keyword.keyword?(style_as_kw_list) do
      raise RuntimeError, "style must be a map or a keyword list"
    end

    %{axis | major_tick_labels_style: style_as_kw_list}
  end

  def put_style(axis, style) do
    style_as_kw_list = Enum.into(style, [])

    unless Keyword.keyword?(style_as_kw_list) do
      raise RuntimeError, "style must be a map or a keyword list"
    end

    %{axis | style: style_as_kw_list}
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

  @doc false
  def tick_size(axis) do
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

  @doc false
  def maybe_add_major_ticks(axis) do
    case {axis.major_tick_locations, axis.major_tick_labels} do
      {nil, nil} ->
        {tick_manager_module, opts} = axis.major_tick_manager
        tick_manager_module.add_major_ticks(axis, opts)

      {locations, labels} when not is_nil(locations) and not is_nil(labels) ->
        axis
    end
  end

  # Gather all bookkeeping here because it iwll get more complex
  def make_major_tick_label(axis, label_text) do
    text_opts = Config.get_major_tick_label_text_attributes(axis.major_tick_labels_style)
    Text.new(label_text, text_opts)
  end

  def draw_bottom_axis(plot, x, y, axis = %Axis2D{location: :bottom}) do
    full_axis_width = axis.margin_start + axis.size + axis.margin_end

    canvas = Canvas.new(prefix: "bottom_axis_canvas")

    Figure.minimize(canvas.height, level: 30)

    Figure.assert(canvas.x == x)
    Figure.assert(canvas.y == y)
    Figure.assert(canvas.width == plot.bottom_decorations_area.width)

    Figure.assert(axis.x == x)
    Figure.assert(axis.y == y)

    Figure.assert(full_axis_width == plot.bottom_decorations_area.width)

    # Add the ticks to the axis if they haven«t been added already
    axis = maybe_add_major_ticks(axis)

    # Draw the axis itself
    _axis_line =
      Line.new(
        x1: x,
        x2: x + canvas.width,
        y1: y,
        y2: y,
        z_level: 0.0,
        prefix: "bottom_axis"
      )

    major_tick_size = Config.get_major_tick_size(axis)

    # But the top of the labels shouldn't be so high (== low y position) that it gets too close...
    # This is how close the top of the labels is allowed to be to the axis
    minimum_tick_label_top =
      Polynomial.algebra(y + major_tick_size + axis.major_tick_label_inner_padding)

    tick_label_baseline = Figure.variable("tick_label_baseline")
    # The baseline should be as close to the axis as allowed by the remaining constraints
    Figure.minimize(tick_label_baseline)
    Figure.assert(tick_label_baseline >= minimum_tick_label_top)

    tick_label_bottom = Figure.variable("tick_label_bottom")
    Figure.minimize(tick_label_bottom)
    Figure.assert(tick_label_bottom >= minimum_tick_label_top)

    for {tick_location, tick_label} <- Enum.zip(axis.major_tick_locations, axis.major_tick_labels) do
      tick_x = Polynomial.variable(AxisData.new(tick_location, plot.id, axis.name))

      Line.new(
        x1: tick_x,
        x2: tick_x,
        y1: y,
        y2: Polynomial.algebra(y + major_tick_size),
        prefix: "bottom_axis_tick"
      )

      label = make_major_tick_label(axis, tick_label)

      # Position the label horizontally
      Figure.assert(Sketch.bbox_center(label) == tick_x)

      # Ensure the label fits inside the plot
      Figure.assert(Sketch.bbox_right(label) <= Sketch.bbox_right(plot.right_decorations_area))
      Figure.assert(Sketch.bbox_left(label) >= Sketch.bbox_left(plot.left_decorations_area))

      case label do
        %Text{rotation: 0} ->
          # Position upright text according to the baseline.
          # The rules for positioning rotated text are in the branch beloww.
          Figure.assert(label.y == tick_label_baseline)
          Figure.assert(Sketch.bbox_top(label) >= minimum_tick_label_top)
          Figure.assert(tick_label_bottom >= Sketch.bbox_bottom(label))

        other ->
          # Position everything else so that the bottom rests on the baseline.
          # This includes rotated text
          Figure.assert(Sketch.bbox_bottom(other) == tick_label_baseline)
          Figure.assert(Sketch.bbox_top(other) >= minimum_tick_label_top)
          Figure.assert(tick_label_bottom >= Sketch.bbox_bottom(other))
      end
    end

    # Assert that the ticks are fully inside the canvas.
    # This constraint will be superseded by a more specific one if
    # the axis has a label; in that case, the bottom limit will be the label.
    Figure.assert(tick_label_bottom <= Sketch.bbox_bottom(canvas))

    # If there is a label, place it in the decorations canvas
    if axis.label do
      # Subtract the y position of the axis because these are relative positions
      relative_y_location = tick_label_bottom + axis.label_inner_padding - y
      # Place the label in the canvas
      Figure.place_in_canvas(
        axis.label,
        canvas,
        x: axis.label_location,
        y: relative_y_location,
        horizontal_alignment: axis.label_alignment,
        vertical_alignment: :top,
        contained_vertically_in_canvas: true,
        contained_horizontally_in_canvas: false
      )
    end

    canvas
  end

  def draw_top_axis(plot, x, y, axis = %Axis2D{location: :top}) do
    canvas = Canvas.new(prefix: "top_axis_canvas")

    Figure.minimize(canvas.height, level: 30)

    Figure.assert(canvas.width == plot.top_decorations_area.width)
    Figure.assert(canvas.x == x)
    Figure.assert(Sketch.bbox_bottom(canvas) == y)

    Figure.assert(axis.x == x)
    Figure.assert(axis.y == y)

    Figure.assert(
      axis.margin_start + axis.size + axis.margin_end == plot.top_decorations_area.width
    )

    axis = maybe_add_major_ticks(axis)

    major_tick_size = Config.get_major_tick_size(axis)

    _line =
      Line.new(
        x1: x,
        x2: x + canvas.width,
        y1: y,
        y2: y,
        prefix: "top_axis"
      )

    # But the top of the labels shouldn't be so high (== low y position) that it gets too close...
    # This is how close the top of the labels is allowed to be to the axis
    maximum_tick_label_bottom =
      Polynomial.algebra(y - major_tick_size - axis.major_tick_label_inner_padding)

    tick_label_baseline = Figure.variable("tick_label_baseline")
    # The baseline should be as close to the axis as allowed by the remaining constraints
    Figure.maximize(tick_label_baseline)
    Figure.assert(tick_label_baseline <= maximum_tick_label_bottom)

    tick_label_top = Figure.variable("tick_label_bottom")
    Figure.maximize(tick_label_top)
    Figure.assert(tick_label_top <= maximum_tick_label_bottom)

    for {tick_location, tick_label} <- Enum.zip(axis.major_tick_locations, axis.major_tick_labels) do
      tick_x = Polynomial.variable(AxisData.new(tick_location, plot.id, axis.name))

      Line.new(
        x1: tick_x,
        x2: tick_x,
        y1: Polynomial.algebra(y - major_tick_size),
        y2: y,
        prefix: "top_axis_tick"
      )

      label = make_major_tick_label(axis, tick_label)

      # Position the label horizontally
      Figure.assert(Sketch.bbox_center(label) == tick_x)

      # Ensure the label fits inside the plot
      Figure.assert(Sketch.bbox_right(label) <= Sketch.bbox_right(plot.right_decorations_area))
      Figure.assert(Sketch.bbox_left(label) >= Sketch.bbox_left(plot.left_decorations_area))

      case label do
        %Text{rotation: 0} ->
          # Position upright text according to the baseline.
          # The rules for positioning rotated text are in the branch beloww.
          Figure.assert(label.y == tick_label_baseline)
          Figure.assert(Sketch.bbox_bottom(label) <= maximum_tick_label_bottom)
          Figure.assert(tick_label_top <= Sketch.bbox_top(label))

          # other ->
          #   # Position everything else so that the bottom rests on the baseline.
          #   # This includes rotated text
          #   Figure.assert(Sketch.bbox_bottom(other) == tick_label_baseline)
          #   Figure.assert(Sketch.bbox_top(other) >= minimum_tick_label_top)
          #   Figure.assert(tick_label_top >= Sketch.bbox_top(other))
      end
    end

    # Assert that the ticks are fully inside the canvas.
    # This constraint will be superseded by a more specific one if
    # the axis has a label; in that case, the bottom limit will be the label.
    Figure.assert(tick_label_top >= Sketch.bbox_top(canvas))

    # If there is a label, place it in the decorations canvas
    if axis.label do
      # Subtract the y position of the axis because these are relative positions
      relative_y_location = tick_label_top - axis.label_inner_padding - Sketch.bbox_top(canvas)
      # Place the label in the canvas
      Figure.place_in_canvas(
        axis.label,
        canvas,
        x: axis.label_location,
        y: relative_y_location,
        horizontal_alignment: axis.label_alignment,
        vertical_alignment: :bottom,
        contained_vertically_in_canvas: true,
        contained_horizontally_in_canvas: false
      )
    end

    canvas
  end

  def draw_left_axis(plot, x, y, axis = %Axis2D{location: :left}) do
    full_axis_height = axis.margin_start + axis.size + axis.margin_end

    canvas = Canvas.new(prefix: "left_axis_canvas")

    Figure.minimize(canvas.width, level: 30)

    Figure.assert(Sketch.bbox_right(canvas) == x)
    Figure.assert(canvas.y == y)
    Figure.assert(canvas.height == plot.left_decorations_area.height)

    Figure.assert(axis.x == x)
    Figure.assert(axis.y == y)

    Figure.assert(full_axis_height == canvas.height)

    # Add the ticks to the axis if they haven't been added already
    axis = maybe_add_major_ticks(axis)

    # Draw the axis itself
    _axis_line =
      Line.new(
        x1: x,
        x2: x,
        y1: y,
        y2: y + canvas.height,
        z_level: 0.0,
        prefix: "left_axis"
      )

    major_tick_size = Config.get_major_tick_size(axis)

    labels_left_bound = Figure.variable("labels_left_bound", min: 0)
    Figure.maximize(labels_left_bound)
    Figure.assert(labels_left_bound <= x - major_tick_size)

    major_tick_lines =
      for tick_location <- axis.major_tick_locations do
        tick_y = Polynomial.variable(AxisData.new(tick_location, plot.id, axis.name))

        tick_line =
          Line.new(
            x1: Polynomial.algebra(x - major_tick_size),
            x2: x,
            y1: tick_y,
            y2: tick_y,
            prefix: "left_axis_tick"
          )

        Figure.assert(tick_line.x1 >= Sketch.bbox_left(canvas))

        # Use this as the bounds in case there are no labels
        Figure.assert(labels_left_bound <= tick_line.x1)

        tick_line
      end

    for {tick_line, tick_label} <- Enum.zip(major_tick_lines, axis.major_tick_labels) do
      tick_y = tick_line.y1

      label = make_major_tick_label(axis, tick_label)

      Figure.assert(Sketch.bbox_horizon(label) == tick_y)

      Figure.assert(
        Sketch.bbox_right(label) == Polynomial.algebra(x - major_tick_size - Length.pt(4))
      )

      Figure.assert(Sketch.bbox_left(label) >= Sketch.bbox_left(canvas))

      Figure.assert(labels_left_bound <= Sketch.bbox_left(label))

      label
    end

    if axis.label do
      relative_x_location =
        Polynomial.algebra(
          labels_left_bound - axis.label_inner_padding - Sketch.bbox_left(canvas)
        )

      Figure.place_in_canvas(
        axis.label,
        canvas,
        x: relative_x_location,
        y: axis.label_location,
        horizontal_alignment: :right,
        vertical_alignment: axis.label_alignment,
        contained_horizontally_in_canvas: true,
        contained_vertically_in_canvas: false
      )
    end

    canvas
  end

  def draw_right_axis(plot, x, y, axis = %Axis2D{location: :right}) do
    canvas = Canvas.new(prefix: "right_axis_canvas")

    Figure.minimize(canvas.width, level: 30)

    Figure.assert(canvas.height == plot.right_decorations_area.height)
    Figure.assert(canvas.x == x)
    Figure.assert(canvas.y == y)

    Figure.assert(axis.x == x)
    Figure.assert(axis.y == y)

    Figure.assert(
      axis.margin_start + axis.size + axis.margin_end == plot.right_decorations_area.height
    )

    axis = maybe_add_major_ticks(axis)

    major_tick_size = Config.get_major_tick_size(axis)

    _line =
      Line.new(
        x1: x,
        x2: x,
        y1: y,
        y2: y + canvas.height,
        prefix: "right_axis"
      )

    labels_right_bound = Figure.variable("labels_right_bound", min: 0)
    Figure.minimize(labels_right_bound)
    Figure.assert(labels_right_bound >= x + major_tick_size)

    major_tick_lines =
      for tick_location <- axis.major_tick_locations do
        tick_y = Polynomial.variable(AxisData.new(tick_location, plot.id, axis.name))

        tick_line =
          Line.new(
            x1: x,
            x2: Polynomial.algebra(x + major_tick_size),
            y1: tick_y,
            y2: tick_y,
            prefix: "right_axis_tick"
          )

        Figure.assert(tick_line.x2 <= Sketch.bbox_right(canvas))

        # Use this as the bounds in case there are no labels
        Figure.assert(labels_right_bound >= tick_line.x2)

        tick_line
      end

    for {tick_line, tick_label} <- Enum.zip(major_tick_lines, axis.major_tick_labels) do
      tick_y = tick_line.y1

      label = make_major_tick_label(axis, tick_label)

      Figure.assert(Sketch.bbox_horizon(label) == tick_y)

      Figure.assert(
        Sketch.bbox_left(label) == Polynomial.algebra(x + major_tick_size + Length.pt(4))
      )

      Figure.assert(Sketch.bbox_right(label) <= Sketch.bbox_right(canvas))

      Figure.assert(labels_right_bound >= Sketch.bbox_right(label))

      label
    end

    if axis.label do
      relative_x_location =
        Polynomial.algebra(
          labels_right_bound + axis.label_inner_padding - Sketch.bbox_left(canvas)
        )

      Figure.place_in_canvas(
        axis.label,
        canvas,
        x: relative_x_location,
        y: axis.label_location,
        horizontal_alignment: :left,
        vertical_alignment: axis.label_alignment,
        contained_horizontally_in_canvas: true,
        contained_vertically_in_canvas: false
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

  def put_major_tick_locations(axis, locations) do
    %{axis | major_tick_locations: locations}
  end

  def put_major_tick_labels(axis, labels) do
    %{axis | major_tick_labels: labels}
  end

  def put_scale(%__MODULE__{} = axis, new_scale) do
    %{axis | scale: new_scale}
  end

  def put_max_value(%__MODULE__{} = axis, new_max_value) do
    if axis.max_value_fixed do
      raise RuntimeError, "maximum value of axis is fixed"
    else
      %{axis | max_value: new_max_value}
    end
  end

  def put_min_value(%__MODULE__{} = axis, new_min_value) do
    if axis.max_value_fixed do
      raise RuntimeError, "minimum value of axis is fixed"
    else
      %{axis | min_value: new_min_value}
    end
  end

  def put_limits(%__MODULE__{} = axis, new_min_value, new_max_value) do
    cond do
      axis.max_value_fixed ->
        raise RuntimeError, "maximum value of axis is fixed"

      axis.min_value_fixed ->
        raise RuntimeError, "minimum value of axis is fixed"

      true ->
        %{axis | min_value: new_min_value, max_value: new_max_value}
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
