defmodule Quartz.Benchmarks.ScatterPlot do
  require Quartz.Figure, as: Figure
  alias Quartz.Plot2D
  alias Quartz.Length
  alias Quartz.ColorMap

  alias Statistics.Distributions.Normal

  @nr_of_points_per_series 60

  def build_plot() do
    :rand.seed(:exsss, {42, 42, 42})

    n = @nr_of_points_per_series

    # Generate some (deterministically random)
    x1 = for _i <- 1..n, do: Normal.rand(0.0, 1.0)
    y1 = for x <- x1, do: 2.0 - 0.5 * x + Normal.rand(0.0, 0.2)

    x2 = for _i <- 1..n, do: Normal.rand(0.5, 2.0)
    y2 = for x <- x2, do: 0.2 + 0.85 * x + Normal.rand(0.0, 0.2)

    figure =
      Figure.new([], fn _fig ->
        [[bounds_A], [bounds_B], [bounds_C]] =
          Figure.bounds_for_plots_in_grid(
            nr_of_rows: 3,
            nr_of_columns: 1,
            padding: Length.pt(16)
          )

          prototype_plot = fn bounds ->
            Plot2D.new()
            # Plot the four datasets
            |> Plot2D.set_bounds(bounds)
            |> Plot2D.draw_scatter_plot(x1, y1)
            |> Plot2D.draw_scatter_plot(x2, y2, x_axis: "x2", y_axis: "y2")
            # Use typst to explicitly style the title and labels ――――――――――――――――――――――――――――――――
            |> Plot2D.put_title("A. Scatter plot (1 color per dataset) - linear scale")
            |> Plot2D.put_major_tick_labels_style(["x", "y"], fill: ColorMap.tab10(0))
            |> Plot2D.put_major_tick_labels_style(["x2", "y2"], fill: ColorMap.tab10(1))
            # The axis labels must be explicitly given by the user.
            # One can overwrite default properties such as text rotation.
            # TODO: support non-text based labels
            |> Plot2D.put_axis_label("x", "x-axis")
            |> Plot2D.put_axis_label("y", "y-axis", text: [rotation: 0])
            |> Plot2D.put_axis_label("x2", "x2-axis")
            |> Plot2D.put_axis_label("y2", "y2-axis", text: [rotation: 0])
            |> Plot2D.put_width_to_height_ratio(1.0)
            # Specify lengths using "common" units such as cm or in instead of pt
            |> Plot2D.put_axes_margins(Length.cm(0.2))
            # Always finalize the plot so that it is added to the figure properly.
            |> Plot2D.finalize()
          end

        _plot_A = prototype_plot.(bounds_A)
        _plot_B = prototype_plot.(bounds_B)
        _plot_C = prototype_plot.(bounds_C)
      end)

    Dantzig.dump_problem_to_file(figure.problem, "problem.lp")
    File.write!("solution.exs", inspect(figure.solution, limit: :infinity, pretty: true))

    svg_path = Path.join([__DIR__, "draw_scatter_plot", "example.svg"])
    Figure.render_to_svg_file!(figure, svg_path)

    png_path = Path.join([__DIR__, "draw_scatter_plot", "example.png"])
    Figure.render_to_png_file!(figure, png_path)
  end
end

Quartz.Benchmarks.ScatterPlot.build_plot()
