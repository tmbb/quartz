defmodule Quartz.Plot2D do
  require Quartz.Figure, as: Figure
  alias Quartz.Canvas
  alias Quartz.Axis2D
  alias Quartz.AxisData
  alias Quartz.AxisReference
  alias Quartz.Circle
  alias Quartz.Line
  alias Quartz.Plot2DElement
  alias Quartz.Length
  alias Quartz.Text
  alias Quartz.Sketch
  alias Quartz.Config
  alias Quartz.Color.RGB

  require Quartz.KeywordSpec, as: KeywordSpec

  alias Dantzig.Polynomial
  use Dantzig.Polynomial.Operators

  @decorations_area_content_padding Length.pt(7)
  @boundaries_padding Length.pt(10)
  @title_inner_padding Length.pt(12)

  defstruct id: nil,
            title: nil,
            title_alignment: :left,
            title_location: :left,
            title_inner_padding: @title_inner_padding,
            padding_top: @boundaries_padding,
            padding_right: @boundaries_padding,
            padding_bottom: @boundaries_padding,
            padding_left: @boundaries_padding,
            top: nil,
            bottom: nil,
            left: nil,
            right: nil,
            current_top_bound: nil,
            current_left_bound: nil,
            current_right_bound: nil,
            current_bottom_bound: nil,
            top_content: [],
            right_content: [],
            bottom_content: [],
            left_content: [],
            top_content_padding: @decorations_area_content_padding,
            bottom_content_padding: @decorations_area_content_padding,
            left_content_padding: @decorations_area_content_padding,
            right_content_padding: @decorations_area_content_padding,
            data: [],
            axes: %{},
            plot_area: nil,
            title_area: nil,
            data_area: nil,
            top_decorations_area: nil,
            top_right_decorations_area: nil,
            right_decorations_area: nil,
            bottom_right_decorations_area: nil,
            bottom_decorations_area: nil,
            bottom_left_decorations_area: nil,
            left_decorations_area: nil,
            top_left_decorations_area: nil

  @type t :: %__MODULE__{}

  def new(opts \\ []) do
    plot_id =
      case Keyword.fetch(opts, :id) do
        {:ok, id} -> id
        :error -> Figure.get_id()
      end

    top = Figure.variable("plot_bounds_top", [])
    bottom = Figure.variable("plot_bounds_bottom", [])
    left = Figure.variable("plot_bounds_left", [])
    right = Figure.variable("plot_bounds_right", [])

    bounds = Keyword.get(opts, :bounds, [])

    plot_area = Canvas.new(prefix: "plot_area")
    title_area = Canvas.new(prefix: "title_area")
    data_area = Canvas.new(prefix: "data_area")
    top_decorations_area = Canvas.new(prefix: "top_decorations_area")
    top_right_decorations_area = Canvas.new(prefix: "top_right_decorations_area")
    right_decorations_area = Canvas.new(prefix: "right_decorations_area")
    bottom_right_decorations_area = Canvas.new(prefix: "bottom_right_decorations_area")
    bottom_decorations_area = Canvas.new(prefix: "bottom_decorations_area")
    bottom_left_decorations_area = Canvas.new(prefix: "bottom_left_decorations_area")
    left_decorations_area = Canvas.new(prefix: "left_decorations_area")
    top_left_decorations_area = Canvas.new(prefix: "top_left_decorations_area")

    left_areas = [
      top_left_decorations_area,
      left_decorations_area,
      bottom_left_decorations_area
    ]

    center_areas = [
      top_decorations_area,
      data_area,
      bottom_decorations_area
    ]

    right_areas = [
      top_right_decorations_area,
      right_decorations_area,
      bottom_right_decorations_area
    ]

    top_areas = [
      top_left_decorations_area,
      top_decorations_area,
      top_right_decorations_area
    ]

    horizon_areas = [
      left_decorations_area,
      data_area,
      right_decorations_area
    ]

    bottom_areas = [
      bottom_left_decorations_area,
      bottom_decorations_area,
      bottom_right_decorations_area
    ]

    # Make the plot_area fit tightly in the given space
    Figure.assert(Sketch.bbox_top(plot_area) == top)
    Figure.assert(Sketch.bbox_left(plot_area) == left)
    Figure.assert(Sketch.bbox_right(plot_area) == right)
    Figure.assert(Sketch.bbox_bottom(plot_area) == bottom)

    # Align areas by rows
    align_top(top_areas)
    align_bottom(top_areas)

    align_top(horizon_areas)
    align_bottom(horizon_areas)

    align_top(bottom_areas)
    align_bottom(bottom_areas)

    # Alin areas by columns
    align_left([title_area | left_areas])
    align_right(left_areas)

    align_left(center_areas)
    align_right(center_areas)

    align_left(right_areas)
    align_right(right_areas)

    stack_horizontally_inside_container(top_areas, plot_area)
    stack_horizontally_inside_container(horizon_areas, plot_area)
    stack_horizontally_inside_container(bottom_areas, plot_area)

    stack_vertically_inside_container([title_area | left_areas], plot_area)
    stack_vertically_inside_container([title_area | center_areas], plot_area)
    stack_vertically_inside_container([title_area | right_areas], plot_area)

    Figure.maximize(data_area.width)
    Figure.maximize(data_area.height)

    Figure.minimize(title_area.height)
    Figure.minimize(top_decorations_area.height)
    Figure.minimize(bottom_decorations_area.height)
    Figure.minimize(right_decorations_area.width)
    Figure.minimize(left_decorations_area.width)

    plot = %__MODULE__{
      id: plot_id,
      title: nil,
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      current_top_bound: nil,
      current_bottom_bound: nil,
      current_left_bound: nil,
      current_right_bound: nil,
      plot_area: plot_area,
      title_area: title_area,
      data_area: data_area,
      top_decorations_area: top_decorations_area,
      top_right_decorations_area: top_right_decorations_area,
      right_decorations_area: right_decorations_area,
      bottom_right_decorations_area: bottom_right_decorations_area,
      bottom_decorations_area: bottom_decorations_area,
      bottom_left_decorations_area: bottom_left_decorations_area,
      left_decorations_area: left_decorations_area,
      top_left_decorations_area: top_left_decorations_area
    }

    plot
    |> set_bounds(bounds)
    |> add_bottom_axis("x")
    |> add_left_axis("y")
    |> add_top_axis("x2")
    |> add_right_axis("y2")
  end

  def set_bounds(plot, bounds) do
    top_bound = Access.get(bounds, :top, 0.0)
    bottom_bound = Access.get(bounds, :bottom, Figure.current_figure_height())
    left_bound = Access.get(bounds, :left, 0.0)
    right_bound = Access.get(bounds, :right, Figure.current_figure_width())

    %{
      plot
      | current_top_bound: top_bound,
        current_bottom_bound: bottom_bound,
        current_left_bound: left_bound,
        current_right_bound: right_bound
    }
  end

  def add_bottom_axis(plot, name, opts \\ []) do
    axis = Axis2D.new(name, Keyword.put(opts, :location, :bottom))
    axis = Axis2D.put_plot_id(axis, plot.id)
    new_axes = Map.put(plot.axes, name, axis)
    new_bottom = [%AxisReference{name: name} | plot.bottom_content]

    %{plot | axes: new_axes, bottom_content: new_bottom}
  end

  def add_top_axis(plot, name, opts \\ []) do
    axis = Axis2D.new(name, Keyword.put(opts, :location, :top))
    axis = Axis2D.put_plot_id(axis, plot.id)
    new_axes = Map.put(plot.axes, name, axis)
    new_top = [%AxisReference{name: name} | plot.top_content]

    %{plot | axes: new_axes, top_content: new_top}
  end

  def add_left_axis(plot, name, opts \\ []) do
    axis = Axis2D.new(name, Keyword.put(opts, :location, :left))
    axis = Axis2D.put_plot_id(axis, plot.id)
    new_axes = Map.put(plot.axes, name, axis)
    new_left = [%AxisReference{name: name} | plot.left_content]

    %{plot | axes: new_axes, left_content: new_left}
  end

  def add_right_axis(plot, name, opts \\ []) do
    axis = Axis2D.new(name, Keyword.put(opts, :location, :right))
    axis = Axis2D.put_plot_id(axis, plot.id)
    new_axes = Map.put(plot.axes, name, axis)
    new_right = [%AxisReference{name: name} | plot.right_content]

    %{plot | axes: new_axes, right_content: new_right}
  end

  def get_axis(plot, name) do
    Map.get(plot.axes, name)
  end

  def fetch_axis(plot, name) do
    Map.fetch(plot.axes, name)
  end

  def fetch_axis!(plot, name) do
    Map.fetch!(plot.axes, name)
  end

  def align_bbox(elements, fun) do
    for {e1, e2} <- Enum.zip(elements, Enum.drop(elements, 1)) do
      Figure.assert(fun.(e1) == fun.(e2))
    end
  end

  def align_top(elements), do: align_bbox(elements, &Sketch.bbox_top/1)
  def align_left(elements), do: align_bbox(elements, &Sketch.bbox_left/1)
  def align_right(elements), do: align_bbox(elements, &Sketch.bbox_right/1)
  def align_bottom(elements), do: align_bbox(elements, &Sketch.bbox_bottom/1)

  def stack_horizontally_inside_container(elements = [_first_element | _], container) do
    first = Enum.at(elements, 0)
    last = Enum.at(elements, -1)

    for {e1, e2} <- Enum.zip(elements, Enum.drop(elements, 1)) do
      Figure.assert(Sketch.bbox_right(e1) == Sketch.bbox_left(e2))
    end

    Figure.assert(Sketch.bbox_left(first) >= Sketch.bbox_left(container))
    Figure.assert(Sketch.bbox_right(last) <= Sketch.bbox_right(container))
  end

  def stack_vertically_inside_container(elements = [_first_element | _], container) do
    first = Enum.at(elements, 0)
    last = Enum.at(elements, -1)

    for {e1, e2} <- Enum.zip(elements, Enum.drop(elements, 1)) do
      Figure.assert(Sketch.bbox_bottom(e1) == Sketch.bbox_top(e2))
    end

    Figure.assert(Sketch.bbox_top(first) >= Sketch.bbox_top(container))
    Figure.assert(Sketch.bbox_bottom(last) <= Sketch.bbox_bottom(container))
  end

  def put_axis_label(plot, axis_name, text, opts \\ []) do
    update_axis(plot, axis_name, fn axis ->
      Axis2D.put_label(axis, text, opts)
    end)
  end

  def put_axis_scale(plot, axis_name, scale) do
    update_axis(plot, axis_name, fn axis ->
      Axis2D.put_scale(axis, scale)
    end)
  end

  def update_axis(plot, axis_name, fun) do
    axis = Map.fetch!(plot.axes, axis_name)
    updated_axis = fun.(axis)
    new_axes = Map.put(plot.axes, axis_name, updated_axis)
    %{plot | axes: new_axes}
  end

  def put_minimum_axis_start_margin(plot, axis_name, value) do
    update_axis(plot, axis_name, fn axis ->
      Axis2D.put_minimum_start_margin(axis, value)
    end)
  end

  def put_minimum_axis_end_margin(plot, axis_name, value) do
    update_axis(plot, axis_name, fn axis ->
      Axis2D.put_minimum_end_margin(axis, value)
    end)
  end

  def put_minimum_axis_margins(plot, axis_name, value) do
    update_axis(plot, axis_name, fn axis ->
      Axis2D.put_minimum_margins(axis, value)
    end)
  end

  def put_axes_margins(plot, value, opts \\ []) do
    axis_names = Keyword.get(opts, :axes, get_axes_names(plot))
    Enum.reduce(axis_names, plot, fn axis_name, plot ->
      put_minimum_axis_margins(plot, axis_name, value)
    end)
  end

  defp get_axes_names(plot) do
    Map.keys(plot.axes)
  end

  def put_title(plot, title, opts \\ []) do
    # Separate the text-related options from the other options
    {user_given_text_opts, opts} = Keyword.pop(opts, :text, [])
    # Merge the user-given text options with the default options for this figure
    text_opts = Config.get_plot_title_text_attributes(user_given_text_opts)

    # Handle the non-text-related options
    alignment = Keyword.get(opts, :alignment, :left)
    location = Keyword.get(opts, :location, :left)

    cond do
      is_binary(title) ->
        text = Text.new(title, text_opts)
        %{plot | title: text, title_location: location, title_alignment: alignment}

      # Find out how we should deal with this
      true ->
        %{plot | title: title, title_location: location, title_alignment: alignment}
    end
  end

  def finalize(plot) do
    plot = fix_bounds(plot)
    :ok = Figure.put_plot_in_current_figure(plot)
    plot
  end

  def draw_bottom_content(plot, padding) do
    x0 = plot.bottom_decorations_area.x
    y0 = plot.bottom_decorations_area.y

    reordered_content = Enum.reverse(plot.bottom_content)

    Enum.reduce(reordered_content, y0, fn element, y ->
      drawn = Plot2DElement.draw(element, plot, x0, y)
      Figure.assert_vertically_contained_in(drawn, plot.bottom_decorations_area)
      Sketch.bbox_bottom(drawn) + padding
    end)

    :ok
  end

  def draw_top_content(plot, padding) do
    x0 = plot.top_decorations_area.x
    y0 = Sketch.bbox_bottom(plot.top_decorations_area)

    reordered_content = Enum.reverse(plot.top_content)

    Enum.reduce(reordered_content, y0, fn element, y ->
      drawn = Plot2DElement.draw(element, plot, x0, y)
      Figure.assert_vertically_contained_in(drawn, plot.top_decorations_area)
      y - Sketch.bbox_height(drawn) - padding
    end)

    :ok
  end

  def draw_left_content(plot, padding) do
    x0 = Sketch.bbox_right(plot.left_decorations_area)
    y0 = plot.left_decorations_area.y

    reordered_content = Enum.reverse(plot.left_content)

    Enum.reduce(reordered_content, x0, fn element, x ->
      drawn = Plot2DElement.draw(element, plot, x, y0)
      Figure.assert_horizontally_contained_in(drawn, plot.left_decorations_area)
      x - Sketch.bbox_width(drawn) - padding
    end)

    :ok
  end

  def draw_right_content(plot, padding) do
    x0 = plot.right_decorations_area.x
    y0 = plot.right_decorations_area.y

    reordered_content = Enum.reverse(plot.right_content)

    Enum.reduce(reordered_content, x0, fn element, x ->
      drawn = Plot2DElement.draw(element, plot, x, y0)
      Figure.assert_horizontally_contained_in(drawn, plot.right_decorations_area)
      Sketch.bbox_right(drawn) + padding
    end)

    :ok
  end

  def draw_title(plot) do
    if plot.title do
      y_offset = -1 * plot.title_inner_padding

      Figure.position_with_location_and_alignment(
        plot.title,
        plot.title_area,
        x_location: :left,
        y_location: :bottom,
        y_offset: y_offset,
        contains_vertically?: true
      )
    end

    :ok
  end

  def draw(plot) do
    draw_title(plot)
    draw_left_content(plot, plot.left_content_padding)
    draw_top_content(plot, plot.top_content_padding)
    draw_right_content(plot, plot.right_content_padding)
    draw_bottom_content(plot, plot.bottom_content_padding)
  end

  def boxplot(plot, _data) do
    plot
  end

  def scatter_plot(plot, data_x, data_y, opts \\ []) do
    KeywordSpec.validate!(opts, style: [], x_axis: "x", y_axis: "y")
    KeywordSpec.validate!(style, [radii, color: RGB.teal(), radius: Length.pt(2)])

    # Convert eveyrthing that might be a polynomial into a number
    data_x = Enum.map(data_x, &Polynomial.to_number!/1)
    data_y = Enum.map(data_y, &Polynomial.to_number!/1)

    if radii do
      # There are multiple radii
      for {x, y, r} <- Enum.zip([data_x, data_y, radii]) do
        # Convert to data
        center_x = AxisData.new(x, plot.id, x_axis) |> Polynomial.variable()
        center_y = AxisData.new(y, plot.id, y_axis) |> Polynomial.variable()

        Circle.new(
          center_x: center_x,
          center_y: center_y,
          radius: r,
          fill: color
        )
      end
    else
      # All circles have the same radius
      for {x, y} <- Enum.zip(data_x, data_y) do
        # Convert to data
        center_x = AxisData.new(x, plot.id, x_axis) |> Polynomial.variable()
        center_y = AxisData.new(y, plot.id, y_axis) |> Polynomial.variable()

        Circle.new(
          center_x: center_x,
          center_y: center_y,
          radius: radius,
          fill: color
        )
      end
    end

    plot
  end

  def line_plot(plot, data_x, data_y, opts \\ []) do
    KeywordSpec.validate!(opts, style: [], x_axis: "x", y_axis: "y")
    KeywordSpec.validate!(style, stroke_cap: "round", color: RGB.teal())

    # Convert eveyrthing that might be a polynomial into a number
    xs = Enum.map(data_x, &Polynomial.to_number!/1)
    ys = Enum.map(data_y, &Polynomial.to_number!/1)

    # 1st point of the line segment
    xy_1 = Enum.zip(xs, ys)
    # 2nd point of the line segment
    xy_2 = Enum.zip(xs, ys) |> Enum.drop(1)

    for {{x1, y1}, {x2, y2}} <- Enum.zip(xy_1, xy_2) do
      # Convert the numeric values into variables
      line_x1 = AxisData.new(x1, plot.id, x_axis) |> Polynomial.variable()
      line_y1 = AxisData.new(y1, plot.id, y_axis) |> Polynomial.variable()
      line_x2 = AxisData.new(x2, plot.id, x_axis) |> Polynomial.variable()
      line_y2 = AxisData.new(y2, plot.id, y_axis) |> Polynomial.variable()

      Line.new(
        x1: line_x1,
        y1: line_y1,
        x2: line_x2,
        y2: line_y2,
        stroke_cap: stroke_cap,
        stroke_paint: color
      )
    end

    plot
  end

  alias Quartz.Statistics.KDE
  alias Explorer.Series

  def kde_plot(plot, values, opts \\ []) do
    value_series =
      case values do
        %Series{} ->
          values

        _other ->
          float_values = Enum.map(values, &Polynomial.to_number!/1)
          Series.from_list(float_values)
      end

    df = KDE.kde(value_series, 200)

    xs = Series.to_list(df[:x])
    ys = Series.to_list(df[:y])

    line_plot(plot, xs, ys, opts)
  end

  def draw_function_contour_plot(plot, fun, x_min, x_max, y_min, y_max, countour_levels, opts \\ []) do
    KeywordSpec.validate!(opts, style: [], x_axis: "x", y_axis: "y", n: 15)
    KeywordSpec.validate!(style, stroke_cap: "round", color: RGB.teal())

    delta_x = Kernel.-(x_max, x_min)
    delta_y = Kernel.-(y_max, y_min)

    x_coords = for i <- 0..Kernel.-(n, 1), do: Kernel.+(x_min, Kernel.*(delta_x, Kernel./(i, n)))
    y_coords = for j <- 0..Kernel.-(n, 1), do: Kernel.+(y_min, Kernel.*(delta_y, Kernel./(j, n)))

    values =
      for x <- x_coords do
        for y <- y_coords do
          fun.(x, y)
        end
      end

    contours = Conrex.conrec(values, x_coords, y_coords, countour_levels)

    for {_level, line_segments} <- contours do
      for line_segment <- line_segments do
        {{x1, y1}, {x2, y2}} = line_segment

        line_x1 = AxisData.new(x1, plot.id, x_axis) |> Polynomial.variable()
        line_y1 = AxisData.new(y1, plot.id, y_axis) |> Polynomial.variable()
        line_x2 = AxisData.new(x2, plot.id, x_axis) |> Polynomial.variable()
        line_y2 = AxisData.new(y2, plot.id, y_axis) |> Polynomial.variable()

        Line.new(
          x1: line_x1,
          y1: line_y1,
          x2: line_x2,
          y2: line_y2,
          stroke_cap: stroke_cap,
          stroke_paint: color
        )
      end
    end

    plot
  end

  defp fix_bounds(plot) do
    top_bound = plot.current_top_bound || 0.0
    bottom_bound = plot.current_bottom_bound || Figure.current_figure_height()
    left_bound = plot.current_left_bound || 0.0
    right_bound = plot.current_right_bound || Figure.current_figure_height()

    bounds = [
      top: top_bound,
      bottom: bottom_bound,
      left: left_bound,
      right: right_bound
    ]

    Figure.assert(plot.top == top_bound)
    Figure.assert(plot.bottom == bottom_bound)
    Figure.assert(plot.left == left_bound)
    Figure.assert(plot.right == right_bound)

    set_bounds(plot, bounds)
  end
end
