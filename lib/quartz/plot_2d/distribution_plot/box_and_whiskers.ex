defmodule Quartz.Plot2D.DistributionPlots.BoxAndWhiskers do
  @moduledoc false
  alias Quartz.LinearPath
  alias Quartz.Line
  alias Quartz.AxisData
  alias Quartz.Plot2D.DistributionPlots.BoxAndWhiskers.Options
  alias Quartz.Plot2D.DistributionPlots.BoxAndWhiskers.DrawParameters

  require Dantzig.Polynomial, as: Polynomial
  require Explorer.Series, as: Series

  @box_width_proportion_coefficient 0.80
  @whisker_tip_width_proportion_coefficient 0.40

  defstruct outliers_bottom: [],
            whisker_bottom: nil,
            q1: nil,
            median: nil,
            q3: nil,
            whisker_top: nil,
            outliers_top: [],
            options: %Options{}

  def from_series(%Series{} = s, opts \\ []) do
    q1 = Series.quantile(s, 0.25)
    median = Series.quantile(s, 0.5)
    q3 = Series.quantile(s, 0.75)
    iqr = q3 - q1
    whisker_bottom = median - 0.75 * iqr
    whisker_top = median + 0.75 * iqr
    outliers_bottom = Series.filter(s, _ < ^whisker_bottom)
    outliers_top = Series.filter(s, _ > ^whisker_top)

    %__MODULE__{
      outliers_bottom: outliers_bottom,
      whisker_bottom: whisker_bottom,
      q1: q1,
      median: median,
      q3: q3,
      whisker_top: whisker_top,
      outliers_top: outliers_top,
      options: Options.new(opts)
    }
  end

  def from_data(data, opts \\ []) do
    case data do
      values when is_list(values) ->
        from_list(data, opts)

      %Series{} ->
        from_series(data, opts)
    end
  end

  def from_list(list, opts \\ []) do
    s = Series.from_list(list)
    from_series(s, opts)
  end

  defp mininum_distance_between_locations(locations) do
    sorted_locations = Enum.sort([1.0 | locations])

    {_loc, min_distance} =
      Enum.reduce(
        sorted_locations,
        {_loc = 0.0, _distance = 1.0},
        fn next_loc, {old_loc, old_distance} ->
          new_distance = next_loc - old_loc

          if new_distance < old_distance do
            {next_loc, new_distance}
          else
            {next_loc, old_distance}
          end
        end
      )

    min_distance
  end

  def draw_vertical_boxes_and_whiskers(groups, draw_parameters, opts) do
    locations = draw_parameters.locations

    min_distance = mininum_distance_between_locations(draw_parameters.locations)

    default_box_width = @box_width_proportion_coefficient * min_distance
    default_whisker_tip_width = @whisker_tip_width_proportion_coefficient * min_distance

    opts =
      opts
      |> Keyword.put_new(:box_width, {:fractional, default_box_width})
      |> Keyword.put_new(:whisker_tip_width, {:fractional, default_whisker_tip_width})

    boxes_and_whiskers = for group <- groups, do: from_data(group, opts)

    for {box_and_whiskers, location} <- Enum.zip(boxes_and_whiskers, locations) do
      draw_vertical_box_and_whiskers(box_and_whiskers, location, draw_parameters, opts)
    end
  end

  def draw_vertical_box_and_whiskers(
        %__MODULE__{} = box_and_whiskers,
        location,
        %DrawParameters{} = draw_parameters,
        _opts \\ []
      ) do
    plot_id = draw_parameters.plot_id
    x_axis = draw_parameters.x_axis
    y_axis = draw_parameters.y_axis

    options = box_and_whiskers.options

    loc = AxisData.new_variable(location, plot_id, x_axis)

    axis_variable = fn value ->
      AxisData.new_variable(value, plot_id, x_axis)
    end

    {left_x, right_x} =
      case box_and_whiskers.options.box_width do
        {:fractional, width} ->
          left_x = axis_variable.(location - 0.5 * width)
          right_x = axis_variable.(location + 0.5 * width)

          {left_x, right_x}

        box_width ->
          Polynomial.algebra do
            left_x = loc - 0.5 * box_width
            right_x = loc + 0.5 * box_width

            {left_x, right_x}
          end
      end

    {whisker_left_x, whisker_right_x} =
      case box_and_whiskers.options.whisker_tip_width do
        {:fractional, width} ->
          whisker_left_x = axis_variable.(location - 0.5 * width)
          whisker_right_x = axis_variable.(location + 0.5 * width)

          {whisker_left_x, whisker_right_x}

        whisker_tip_width ->
          Polynomial.algebra do
            whisker_left_x = loc - 0.5 * whisker_tip_width
            whisker_right_x = loc + 0.5 * whisker_tip_width

            {whisker_left_x, whisker_right_x}
          end
      end

    whisker_bottom = AxisData.new_variable(box_and_whiskers.whisker_bottom, plot_id, y_axis)
    q1 = AxisData.new_variable(box_and_whiskers.q1, plot_id, y_axis)
    median = AxisData.new_variable(box_and_whiskers.median, plot_id, y_axis)
    q3 = AxisData.new_variable(box_and_whiskers.q3, plot_id, y_axis)
    whisker_top = AxisData.new_variable(box_and_whiskers.whisker_top, plot_id, y_axis)

    _top_rect =
      LinearPath.draw_new(
        prefix: "box_and_whiskers_top_rect",
        points: [
          {left_x, median},
          {left_x, q3},
          {right_x, q3},
          {right_x, median}
        ],
        stroke_paint: "none",
        closed: true,
        fill: options.top_fill
      )

    _bottom_rect =
      LinearPath.draw_new(
        prefix: "box_and_whiskers_bottom_rect",
        points: [
          {left_x, median},
          {left_x, q1},
          {right_x, q1},
          {right_x, median}
        ],
        stroke_paint: "none",
        closed: true,
        fill: options.bottom_fill
      )

    # Stroke around the rectangles
    # ----------------------------
    # The strokes don't include the median line which is part of both rectangles
    # (the bottom of the top rectangle and the top of the bottom rectangle)
    # The median line is drawn separately so that it can have custom properties

    _top_rect_open_stroke =
      LinearPath.draw_new(
        prefix: "box_and_whiskers_top_rect_stroke",
        points: [
          {left_x, median},
          {left_x, q3},
          {right_x, q3},
          {right_x, median}
        ],
        closed: false,
        fill: "none"
      )

    _bottom_rect_open_stroke =
      LinearPath.draw_new(
        prefix: "box_and_whiskers_bottom_rect",
        points: [
          {left_x, median},
          {left_x, q1},
          {right_x, q1},
          {right_x, median}
        ],
        closed: false,
        fill: "none"
      )

    # The median line
    # ---------------------------------------------

    _median_line =
      Line.draw_new(
        prefix: "bottom_whisker_shaft",
        x1: left_x,
        y1: median,
        x2: right_x,
        y2: median
      )

    # The whiskers
    # ---------------------------------------------

    _bottom_whisker_shaft =
      Line.draw_new(
        prefix: "bottom_whisker_shaft",
        x1: loc,
        y1: q3,
        x2: loc,
        y2: whisker_top
      )

    _bottom_whisker_shaft =
      Line.draw_new(
        prefix: "top_whisker_shaft",
        x1: loc,
        y1: q1,
        x2: loc,
        y2: whisker_bottom
      )

    _top_whisker_tip =
      Line.draw_new(
        prefix: "bottom_whisker_tip",
        x1: whisker_left_x,
        y1: whisker_bottom,
        x2: whisker_right_x,
        y2: whisker_bottom
      )

    _bottom_whisker_tip =
      Line.draw_new(
        prefix: "bottom_whisker_tip",
        x1: whisker_left_x,
        y1: whisker_top,
        x2: whisker_right_x,
        y2: whisker_top
      )
  end
end
