defmodule Quartz.Plot2D.DistributionPlot do
  @moduledoc false

  alias Quartz.Statistics.KDE
  alias Quartz.Plot2D.PairwiseDataPlot
  alias Explorer.Series
  require Explorer.DataFrame, as: DataFrame
  require Quartz.KeywordSpec, as: KeywordSpec
  alias Quartz.LinearPath
  alias Dantzig.Polynomial
  alias Quartz.Plot2D
  alias Quartz.AxisData

  alias Quartz.Plot2D.DistributionPlots.BoxAndWhiskers

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

    PairwiseDataPlot.draw_line_plot(plot, xs, ys, opts)
  end

  def kde_plot_groups_from_dataframe(plot, %DataFrame{} = dataframe, group_column, values_column, color_picker, opts \\ []) do
    groups =
      dataframe[group_column]
      |> Series.distinct()
      |> Series.sort()
      |> Series.to_list()

    Enum.reduce(groups, plot, fn new_group, plot ->
      {new_plot, new_opts} = color_picker.(plot, opts)
      values =
        DataFrame.filter_with(
          dataframe,
          fn df -> Series.equal(df[group_column], new_group) end
        )[values_column]

      kde_plot(new_plot, values, new_opts)
    end)
  end

  defp box_plot_default_labels(nr_of_groups) do
    for i <- 1..nr_of_groups do
      "#{i}"
    end
  end

  defp box_plot_default_tick_locations(nr_of_groups) do
    for i <- 1..nr_of_groups do
      (i - 0.5) / nr_of_groups
    end
  end

  def box_plot(plot, groups, opts \\ []) when is_list(groups) do
    nr_of_groups = length(groups)

    KeywordSpec.validate!(opts, [
      x_axis: "x",
      y_axis: "y",
      labels: box_plot_default_labels(nr_of_groups),
      x_tick_locations: box_plot_default_tick_locations(nr_of_groups)
    ])

    draw_parameters =
      %BoxAndWhiskers.DrawParameters{
        plot_id: plot.id,
        x_axis: x_axis,
        y_axis: y_axis,
        locations: x_tick_locations,
        nr_of_groups: length(groups)
      }

      BoxAndWhiskers.draw_vertical_boxes_and_whiskers(groups, draw_parameters, opts)

    plot
    |> Plot2D.put_axis_major_tick_locations(x_axis, x_tick_locations)
    |> Plot2D.put_axis_major_tick_labels(x_axis, labels)
    |> Plot2D.put_axis_limits(x_axis, 0.0, 1.0)
  end


  defp to_series(%Series{} = s), do: s
  defp to_series(values) when is_list(values), do: Series.from_list(values)

  @doc false
  def default_bin_width_for_histogram(series) do
    n = Series.count(series)
    q1 = Series.quantile(series, 0.25)
    q3 = Series.quantile(series, 0.75)
    iqr = q3 - q1

    2 * iqr / (:math.pow(n, 1/3))
  end

  def histogram(plot, data, opts \\ []) do
    series = to_series(data)

    KeywordSpec.validate!(opts, [
      x_axis: "x",
      y_axis: "y",
      normalized: false,
      ideal_bin_width: default_bin_width_for_histogram(series)
    ])

    to_x_axis_data = fn value ->
      AxisData.new_variable(value, plot.id, x_axis)
    end

    to_y_axis_data = fn value ->
      AxisData.new_variable(value, plot.id, y_axis)
    end

    min = Series.min(series)
    max = Series.max(series)

    nr_of_points = Series.count(series)

    nr_of_bins = round(:math.ceil((max - min) / ideal_bin_width))
    cut_points = for i <- 1..nr_of_bins, do: min + (i * (max - min) / (nr_of_bins + 1))

    absolute_counts =
      series
      |> Series.cut(cut_points)
      |> Access.get(:break_point)
      |> Series.frequencies()
      |> DataFrame.sort_by(values)
      |> Access.get(:counts)

    counts =
      if normalized do
        absolute_counts
        |> Series.divide(nr_of_points)
        |> Series.to_list()
      else
        Series.to_list(absolute_counts)
      end

    all_bounds = Enum.map([min | cut_points] ++ [max], to_x_axis_data)

    lower_bounds = Enum.drop(all_bounds, -1)
    upper_bounds = Enum.drop(all_bounds, 1)

    bounds = Enum.zip(lower_bounds, upper_bounds)

    pairs_of_points =
      for {count, {x1, x2}} <- Enum.zip(counts, bounds) do
        count_axis_data = to_y_axis_data.(count)
        [{x1, count_axis_data}, {x2, count_axis_data}]
      end

    all_points =
      List.flatten([
        {to_x_axis_data.(min), to_y_axis_data.(0)},
        pairs_of_points,
        {to_x_axis_data.(max), to_y_axis_data.(0)}
      ])

    LinearPath.new(
      histogram: "histogram",
      points: all_points,
      stroke_paint: "none",
      closed: true,
      fill: "cyan"
    )

    plot
  end
end