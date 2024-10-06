defmodule Quartz.Plot2D.PairwiseDataPlot do
  @moduledoc false
  alias Explorer.Series

  alias Quartz.AxisData
  alias Quartz.LinearPath
  alias Quartz.Circle
  alias Quartz.Plot2D
  alias Quartz.Length
  alias Quartz.Legend

  require Quartz.KeywordSpec, as: KeywordSpec

  alias Dantzig.Polynomial

  def draw_filled_between_y(plot, data_x, data_y, opts \\ []) do
    KeywordSpec.validate!(opts,
      bottom: 0.0,
      x_axis: "x",
      y_axis: "y",
      style: [],
      label: nil,
      legend_symbol: :rectangle
    )

    KeywordSpec.validate!(style, [
      !color,
      stroke_cap: "round",
      stroke_join: nil,
      stroke_dash: nil,
      stroke_thickness: 0.0,
      opacity: 1
    ])

    # Convert everything that might be a polynomial into a number
    # TODO: do we want to allow polynomials here?
    data_x = Enum.map(data_x, &Polynomial.to_number!/1)
    data_y = Enum.map(data_y, &Polynomial.to_number!/1)

    {min_x, max_x} = Enum.min_max(data_x)

    path_points =
      for {x, y} <- Enum.zip(data_x, data_y) do
        # Convert the numeric values into variables
        path_x = AxisData.new_variable(x, plot.id, x_axis)
        path_y = AxisData.new_variable(y, plot.id, y_axis)

        {path_x, path_y}
      end

    path_points =
      [
        {AxisData.new_variable(min_x, plot.id, x_axis),
         AxisData.new_variable(bottom, plot.id, y_axis)}
        | path_points
      ] ++
        [
          {AxisData.new_variable(max_x, plot.id, x_axis),
           AxisData.new_variable(bottom, plot.id, y_axis)}
        ]

    LinearPath.draw_new(
      points: path_points,
      closed: true,
      fill: color,
      opacity: opacity,
      stroke_paint: color,
      stroke_cap: stroke_cap,
      stroke_join: stroke_join,
      stroke_dash: stroke_dash,
      stroke_thickness: stroke_thickness
    )

    if label && plot.has_legend do
      symbol_properties = [
        fill: color,
        opacity: opacity,
        stroke_thickness: stroke_thickness,
        stroke_paint: color
      ]

      symbol = Legend.symbol_for_color(legend_symbol, symbol_properties)

      Plot2D.add_to_legend(plot, symbol, label)
    else
      plot
    end
  end

  def to_data(list) when is_list(list), do: list
  def to_data(%Series{} = series), do: Series.to_list(series)

  def draw_line_plot(%Plot2D{} = plot, data_x, data_y, opts \\ []) do
    # Assumes the color has been already selected
    KeywordSpec.validate!(opts,
      style: [],
      x_axis: "x",
      y_axis: "y",
      label: nil,
      legend_symbol: :line
    )

    KeywordSpec.validate!(style, [
      !color,
      stroke_cap: "round",
      stroke_join: nil,
      stroke_dash: nil,
      stroke_thickness: 1
    ])

    data_x = to_data(data_x)
    data_y = to_data(data_y)

    # Convert everything that might be a polynomial into a number
    # TODO: do we want to allow polynomials here?
    data_x = Enum.map(data_x, &Polynomial.to_number!/1)
    data_y = Enum.map(data_y, &Polynomial.to_number!/1)

    path_points =
      for {x, y} <- Enum.zip(data_x, data_y) do
        # Convert the numeric values into variables
        path_x = AxisData.new(x, plot.id, x_axis) |> Polynomial.variable()
        path_y = AxisData.new(y, plot.id, y_axis) |> Polynomial.variable()

        {path_x, path_y}
      end

    LinearPath.draw_new(
      points: path_points,
      closed: false,
      stroke_paint: color,
      stroke_cap: stroke_cap,
      stroke_join: stroke_join,
      stroke_dash: stroke_dash,
      stroke_thickness: stroke_thickness
    )

    if label && plot.has_legend do
      symbol_properties = [
        fill: color,
        stroke_thickness: stroke_thickness,
        stroke_paint: color
      ]

      symbol = Legend.symbol_for_color(legend_symbol, symbol_properties)

      Plot2D.add_to_legend(plot, symbol, label)
    else
      plot
    end
  end

  def draw_bar_plot(plot, _data_x, _data_y, _opts \\ []) do
    plot
  end

  def draw_scatter_plot(plot, data_x, data_y, opts \\ []) do
    KeywordSpec.validate!(opts,
      style: [],
      x_axis: "x",
      y_axis: "y",
      label: nil,
      legend_symbol: :circle
    )

    KeywordSpec.validate!(style, [
      radii,
      !color,
      opacity: 1,
      stroke: nil,
      stroke_paint: nil,
      stroke_thickness: nil,
      radius: Length.pt(2)
    ])

    # Convert everything that might be a polynomial into a number
    # TODO: do we want to allow polynomials here?
    data_x = Enum.map(data_x, &Polynomial.to_number!/1)
    data_y = Enum.map(data_y, &Polynomial.to_number!/1)

    if radii do
      # There are multiple radii
      for {x, y, r} <- Enum.zip([data_x, data_y, radii]) do
        # Convert to data
        center_x = AxisData.new(x, plot.id, x_axis) |> Polynomial.variable()
        center_y = AxisData.new(y, plot.id, y_axis) |> Polynomial.variable()

        Circle.draw_new(
          center_x: center_x,
          center_y: center_y,
          radius: r,
          fill: color,
          opacity: opacity,
          stroke: stroke,
          stroke_paint: stroke_paint,
          stroke_thickness: stroke_thickness
        )
      end
    else
      # All circles have the same radius
      for {x, y} <- Enum.zip(data_x, data_y) do
        # Convert to data
        center_x = AxisData.new(x, plot.id, x_axis) |> Polynomial.variable()
        center_y = AxisData.new(y, plot.id, y_axis) |> Polynomial.variable()

        Circle.draw_new(
          center_x: center_x,
          center_y: center_y,
          radius: radius,
          fill: color,
          opacity: opacity,
          stroke: stroke,
          stroke_paint: stroke_paint,
          stroke_thickness: stroke_thickness
        )
      end
    end

    if label && plot.has_legend do
      symbol_properties = [
        fill: color,
        stroke_thickness: stroke_thickness,
        stroke_paint: color
      ]

      symbol = Legend.symbol_for_color(legend_symbol, symbol_properties)

      Plot2D.add_to_legend(plot, symbol, label)
    else
      plot
    end
  end
end
