defmodule Quartz.Plot2D do
  require Quartz.Figure, as: Figure
  alias Quartz.Canvas
  alias Quartz.Axis2D
  alias Quartz.AxisReference
  alias Quartz.Plot2DElement
  alias Quartz.Length
  alias Quartz.Text
  alias Quartz.Sketch
  alias Quartz.Config
  alias Quartz.ColorMap

  alias Quartz.Plot2D.PairwiseDataPlot
  alias Quartz.Plot2D.DistributionPlot
  alias Quartz.Plot2D.GriddedDataPlot

  require Quartz.KeywordSpec, as: KeywordSpec

  alias Explorer.DataFrame

  require Dantzig.Polynomial, as: Polynomial

  @decorations_area_content_padding Length.pt(7)
  @boundaries_padding Length.pt(10)
  @title_inner_padding Length.pt(6)

  @default_color_map ColorMap.tab10()

  @derive {Inspect, only: [:id, :title]}

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
            top_margin: nil,
            right_margin: nil,
            bottom_margin: nil,
            left_margin: nil,
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
            top_left_decorations_area: nil,
            categorical_color_map: @default_color_map,
            categorical_color_index: 0,
            width_to_aspect_ratio: nil

  @type t :: %__MODULE__{}

  def new(opts \\ []) do
    KeywordSpec.validate!(opts,
      id: nil,
      categorical_color_map: @default_color_map
    )

    id =
      case id do
        nil ->
          default_id_suffix = Figure.get_id()
          "plot_#{default_id_suffix}"

        other ->
          other
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

    Figure.minimize(title_area.height)
    Figure.minimize(top_decorations_area.height)
    Figure.minimize(bottom_decorations_area.height)
    Figure.minimize(right_decorations_area.width)
    Figure.minimize(left_decorations_area.width)

    Figure.assert(
      title_area.height + top_decorations_area.height +
        data_area.height + bottom_decorations_area.height == plot_area.height
    )

    Figure.assert(
      left_decorations_area.width + data_area.width +
        right_decorations_area.width == plot_area.width
    )

    plot = %__MODULE__{
      id: id,
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
      top_left_decorations_area: top_left_decorations_area,
      categorical_color_map: categorical_color_map
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

    # The margin is based on the label size of the figure
    label_opts = Config.get_axis_label_text_attributes([])
    font_size = Keyword.fetch!(label_opts, :size)
    default_margin_size = Kernel.*(0.25, font_size)

    top_margin = plot.top_margin || default_margin_size
    right_margin = plot.right_margin || default_margin_size
    bottom_margin = plot.bottom_margin || default_margin_size
    left_margin = plot.left_margin || default_margin_size

    # Correct the bounds according to the margins we've specified
    top_bound_with_margin = Polynomial.algebra(top_bound + top_margin)
    right_bound_with_margin = Polynomial.algebra(right_bound - right_margin)
    bottom_bound_with_margin = Polynomial.algebra(bottom_bound - bottom_margin)
    left_bound_with_margin = Polynomial.algebra(left_bound + left_margin)

    %{
      plot
      | current_top_bound: top_bound_with_margin,
        current_right_bound: right_bound_with_margin,
        current_bottom_bound: bottom_bound_with_margin,
        current_left_bound: left_bound_with_margin
    }
  end

  defguardp is_axes(axes) when is_list(axes) or is_binary(axes)

  def put_major_tick_labels_style(plot, axes_name, style) when is_axes(axes_name) do
    axes_name = List.wrap(axes_name)

    update_axes(plot, axes_name, fn axis ->
      Axis2D.put_major_tick_labels_style(axis, style)
    end)
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

  def put_axis_max_value(plot, axis_name, value) do
    update_axis(plot, axis_name, fn axis ->
      Axis2D.put_max_value(axis, value)
    end)
  end

  def put_axis_min_value(plot, axis_name, value) do
    update_axis(plot, axis_name, fn axis ->
      Axis2D.put_max_value(axis, value)
    end)
  end

  def put_axis_limits(plot, axis_name, min_value, max_value) do
    update_axis(plot, axis_name, fn axis ->
      Axis2D.put_limits(axis, min_value, max_value)
    end)
  end

  def put_axis_label(plot, axis_name, text, opts \\ []) do
    update_axis(plot, axis_name, fn axis ->
      Axis2D.put_label(axis, text, opts)
    end)
  end

  def put_width_to_height_ratio(plot, ratio) when is_number(ratio) do
    %{plot | width_to_aspect_ratio: ratio}
  end

  def remove_axis_ticks(plot, axis_name) do
    update_axis(plot, axis_name, fn axis ->
      axis
      |> Axis2D.put_major_tick_locations([])
      |> Axis2D.put_major_tick_labels([])
    end)
  end

  def put_axis_major_tick_locations(plot, axis_name, locations) do
    update_axis(plot, axis_name, fn axis ->
      Axis2D.put_major_tick_locations(axis, locations)
    end)
  end

  def put_axis_major_tick_labels(plot, axis_name, labels) do
    update_axis(plot, axis_name, fn axis ->
      Axis2D.put_major_tick_labels(axis, labels)
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

  def update_axes(plot, axis_names, fun) do
    Enum.reduce(axis_names, plot, fn axis_name, current_plot ->
      update_axis(current_plot, axis_name, fun)
    end)
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
    prefix = "plot_title"
    # Separate the text-related options from the other options
    {user_given_text_opts, opts} = Keyword.pop(opts, :text, [])
    # Merge the user-given text options with the default options for this figure
    text_opts = Config.get_plot_title_text_attributes(user_given_text_opts)
    # Add the prefix for better debugging
    text_opts = [{:prefix, prefix} | text_opts]

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

    # Set the aspect ratio if given
    if plot.width_to_aspect_ratio do
      Figure.assert(
        plot.data_area.width ==
          plot.width_to_aspect_ratio * plot.data_area.height
      )
    end

    # Add the plot to the figure so that the figure machinery
    # can handle the converting of scales and things like that.
    :ok = Figure.put_plot_in_current_figure(plot)

    plot
  end

  def finalize_all(plots) do
    Enum.map(plots, &finalize/1)
  end

  def draw_bottom_content(plot, padding) do
    x0 = plot.bottom_decorations_area.x
    y0 = plot.bottom_decorations_area.y

    reordered_content = Enum.reverse(plot.bottom_content)

    Enum.reduce(reordered_content, y0, fn element, y ->
      drawn = Plot2DElement.draw(element, plot, x0, y)
      Figure.assert_vertically_contained_in(drawn, plot.bottom_decorations_area)
      Polynomial.algebra(Sketch.bbox_bottom(drawn) + padding)
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
      Polynomial.algebra(y - Sketch.bbox_height(drawn) - padding)
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
      Polynomial.algebra(x - Sketch.bbox_width(drawn) - padding)
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
      Polynomial.algebra(Sketch.bbox_right(drawn) + padding)
    end)

    :ok
  end

  def draw_title(plot) do
    if plot.title do
      y_offset = Polynomial.algebra(-1 * plot.title_inner_padding)

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

  def maybe_next_color_from_colormap(plot, opts) do
    # Validate the color and alpha from the style
    KeywordSpec.validate!(opts, style: [])
    KeywordSpec.validate!(style, color: nil, alpha: nil)

    if color do
      # If the color was given, return the given color and the plot unchanged
      {color, plot}
    else
      # If no color is given, get it from the colormap
      index = plot.categorical_color_index
      next_color = ColorMap.get_color(plot.categorical_color_map, index)

      # Update the color's alpha if given
      next_color =
        if alpha do
          %{next_color | alpha: alpha}
        else
          next_color
        end

      new_plot = %{plot | categorical_color_index: Kernel.+(index, 1)}

      {next_color, new_plot}
    end
  end

  def box_plot(plot, groups, opts \\ []) do
    # Choose the color here to avoid recursive cross-module calls
    {new_plot, new_opts} = maybe_add_color_to_opts_from_colormap(plot, opts)
    # Plot the line with the color already picked
    DistributionPlot.box_plot(new_plot, groups, new_opts)
  end

  def maybe_add_color_to_opts_from_colormap(plot, opts) do
    {default_color, plot} = maybe_next_color_from_colormap(plot, opts)
    style = Keyword.get(opts, :style, [])
    style_with_color = Keyword.put_new(style, :color, default_color)
    opts_with_color = Keyword.put(opts, :style, style_with_color)

    # Return the options with a color defined in the style
    {plot, opts_with_color}
  end

  @doc """
  Draw a scatter plot for the given points.
  """
  def draw_scatter_plot(%__MODULE__{} = plot, data_x, data_y, opts \\ []) do
    # Choose the color here to avoid recursive cross-module calls
    {plot, opts} = maybe_add_color_to_opts_from_colormap(plot, opts)
    # Plot the line with the color already picked
    PairwiseDataPlot.draw_scatter_plot(plot, data_x, data_y, opts)
  end

  @doc """
  Draw a series of line segments between the given points.
  """
  def draw_line_plot(%__MODULE__{} = plot, data_x, data_y, opts \\ []) do
    # Choose the color here to avoid recursive cross-module calls
    {new_plot, new_opts} = maybe_add_color_to_opts_from_colormap(plot, opts)
    # Plot the line with the color already picked
    PairwiseDataPlot.draw_line_plot(new_plot, data_x, data_y, new_opts)
  end

  @doc """
  Draw a series of line segments between the given points.
  """
  def draw_function_contour_plot(
        %__MODULE__{} = plot,
        fun,
        x_min,
        x_max,
        y_min,
        y_max,
        countour_levels,
        opts \\ []
      ) do
    # Choose the color here to avoid recursive cross-module calls
    {new_plot, new_opts} = maybe_add_color_to_opts_from_colormap(plot, opts)

    # Plot the line with the color already picked
    GriddedDataPlot.draw_function_contour_plot(
      new_plot,
      fun,
      x_min,
      x_max,
      y_min,
      y_max,
      countour_levels,
      new_opts
    )
  end

  @doc """
  Draw a distribution using a kernel density estimate.
  """
  def kde_plot(plot, values, opts \\ []) do
    # Choose the color here to avoid recursive cross-module calls
    {new_plot, new_opts} = maybe_add_color_to_opts_from_colormap(plot, opts)
    # Plot the line with the color already picked
    DistributionPlot.kde_plot(new_plot, values, new_opts)
  end

  @doc """
  Draw a distribution using a kernel density estimate.
  """
  def kde_plot_groups_from_dataframe(plot, %DataFrame{} = dataframe, group_column, values_column, opts \\ []) do
    DistributionPlot.kde_plot_groups_from_dataframe(
      plot,
      dataframe,
      group_column,
      values_column,
      &maybe_add_color_to_opts_from_colormap/2,
      opts
    )
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

  def draw_histogram(plot, data, opts \\ []) do
    # Choose the color here to avoid recursive cross-module calls
    {new_plot, new_opts} = maybe_add_color_to_opts_from_colormap(plot, opts)
    # Plot the line with the color already picked
    DistributionPlot.histogram(new_plot, data, new_opts)
  end
end
