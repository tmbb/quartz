defmodule Quartz.Benchmarks.AspectRatioScatterPlot do
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

    figure =
      Figure.new([], fn _fig ->
        [[bounds_A], [bounds_B], [bounds_C]] =
          Figure.bounds_for_plots_in_grid(
            nr_of_rows: 3,
            nr_of_columns: 1,
            padding: Length.pt(16)
          )


        prototype_plot = fn id ->
          Plot2D.new(id: id)
          # Plot the four datasets
          |> Plot2D.draw_scatter_plot(x1, y1)
          # The axis labels must be explicitly given by the user.
          # One can overwrite default properties such as text rotation.
          # TODO: support non-text based labels
          |> Plot2D.put_axis_label("x", "x-axis")
          |> Plot2D.put_axis_label("y", "y-axis", text: [rotation: 0])
          # Specify lengths using "common" units such as cm or in instead of pt
          |> Plot2D.put_axes_margins(Length.cm(0.2))
          # Always finalize the plot so that it is added to the figure properly.
          |> Plot2D.finalize()
        end

        _plot_A =
          prototype_plot.("plot_A")
          |> Plot2D.set_bounds(bounds_A)
          |> Plot2D.put_title("A. Default aspect ratio")
          |> Plot2D.finalize()

        _plot_B =
          prototype_plot.("plot_B")
          |> Plot2D.set_bounds(bounds_B)
          |> Plot2D.put_title("B. 1:1 aspect ratio")
          # |> Plot2D.put_width_to_height_ratio(1.0)
          |> Plot2D.finalize()

        _plot_C =
          prototype_plot.("plot_C")
          |> Plot2D.set_bounds(bounds_C)
          |> Plot2D.put_title("C. 1:2 aspect ratio")
          # |> Plot2D.put_width_to_height_ratio(0.5)
          |> Plot2D.finalize()
      end)

    svg_path = Path.join([__DIR__, "aspect_ratio", "example.svg"])
    Figure.render_to_svg_file!(figure, svg_path)

    png_path = Path.join([__DIR__, "aspect_ratio", "example.png"])
    Figure.render_to_png_file!(figure, png_path)
  end
end

Quartz.Benchmarks.AspectRatioScatterPlot.build_plot()
