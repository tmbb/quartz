defmodule Quartz.Plot2D.GriddedDataPlot do
  @moduledoc false
  alias Quartz.AxisData
  alias Quartz.Line
  alias Quartz.Plot2D
  alias Quartz.Figure

  require Quartz.KeywordSpec, as: KeywordSpec

  def draw_function_contour_plot(
        %Plot2D{} = plot,
        fun,
        x_min,
        x_max,
        y_min,
        y_max,
        countour_levels,
        opts \\ []
      ) do
    KeywordSpec.validate!(opts, style: [], x_axis: "x", y_axis: "y", n: 100)

    KeywordSpec.validate!(style, [
      !color,
      stroke_cap: "round",
      stroke_join: nil,
      stroke_dash: nil,
      stroke_thickness: nil
    ])

    _ = stroke_join
    _ = stroke_dash
    _ = stroke_thickness

    delta_x = x_max - x_min
    delta_y = y_max - y_min

    x_coords = for i <- 0..(n - 1), do: x_min + delta_x * (i / n)
    y_coords = for j <- 0..(n - 1), do: y_min + delta_y * (j / n)

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

        line_x1 = AxisData.new(x1, plot.id, x_axis) |> Figure.variable()
        line_y1 = AxisData.new(y1, plot.id, y_axis) |> Figure.variable()
        line_x2 = AxisData.new(x2, plot.id, x_axis) |> Figure.variable()
        line_y2 = AxisData.new(y2, plot.id, y_axis) |> Figure.variable()

        Line.draw_new(
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

  # def function_contour_plot(plot, fun, x_min, x_max, y_min, y_max, countour_levels, opts \\ []) do
  #   KeywordSpec.validate!(opts, style: [], x_axis: "x", y_axis: "y", n: 100)
  #   KeywordSpec.validate!(style, stroke_cap: "round", color: RGB.teal())

  #   delta_x = Kernel.-(x_max, x_min)
  #   delta_y = Kernel.-(y_max, y_min)

  #   x_coords = for i <- 0..Kernel.-(n, 1), do: Kernel.+(x_min, Kernel.*(delta_x, Kernel./(i, n)))
  #   y_coords = for j <- 0..Kernel.-(n, 1), do: Kernel.+(y_min, Kernel.*(delta_y, Kernel./(j, n)))

  #   values =
  #     for x <- x_coords do
  #       for y <- y_coords do
  #         fun.(x, y)
  #       end
  #     end

  #   contours = Conrex.conrec(values, x_coords, y_coords, countour_levels)

  #   for {_level, line_segments} <- contours do
  #     for line_segment <- line_segments do
  #       {{x1, y1}, {x2, y2}} = line_segment

  #       line_x1 = AxisData.new(x1, plot.id, x_axis) |> Polynomial.variable()
  #       line_y1 = AxisData.new(y1, plot.id, y_axis) |> Polynomial.variable()
  #       line_x2 = AxisData.new(x2, plot.id, x_axis) |> Polynomial.variable()
  #       line_y2 = AxisData.new(y2, plot.id, y_axis) |> Polynomial.variable()

  #       Line.draw_new(
  #         x1: line_x1,
  #         y1: line_y1,
  #         x2: line_x2,
  #         y2: line_y2,
  #         stroke_cap: stroke_cap,
  #         stroke_paint: color
  #       )
  #     end
  #   end

  #   plot
  # end
end
