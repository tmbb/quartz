defmodule Quartz.Plot2D.PairwiseDataPlot do
  @moduledoc false
  alias Quartz.AxisData
  alias Quartz.LinearPath
  alias Quartz.Circle
  alias Quartz.Plot2D
  alias Quartz.Length

  require Quartz.KeywordSpec, as: KeywordSpec

  alias Dantzig.Polynomial

  def draw_line_plot(%Plot2D{} = plot, data_x, data_y, opts \\ []) do
    # Assumes the color has been already selected
    KeywordSpec.validate!(opts, style: [], x_axis: "x", y_axis: "y")

    KeywordSpec.validate!(style, [
      !color,
      stroke_cap: "round",
      stroke_join: nil,
      stroke_dash: nil,
      stroke_thickness: nil
    ])

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

    LinearPath.new(
      points: path_points,
      closed: false,
      stroke_paint: color,
      stroke_cap: stroke_cap,
      stroke_join: stroke_join,
      stroke_dash: stroke_dash,
      stroke_thickness: stroke_thickness
    )

    plot
  end

  def draw_scatter_plot(plot, data_x, data_y, opts \\ []) do
    KeywordSpec.validate!(opts, style: [], x_axis: "x", y_axis: "y")
    KeywordSpec.validate!(style, [radii, !color, radius: Length.pt(2)])

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
end
