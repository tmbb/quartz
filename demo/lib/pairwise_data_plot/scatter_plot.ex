defmodule Quartz.Demo.PairwiseDataPlot.ScatterPlot do
  @moduledoc false
  require Quartz.Figure, as: Figure
  alias Quartz.Plot2D
  alias Quartz.Length

  alias Statistics.Distributions.Normal

  @nr_of_points_per_series 60

  def draw(dir) do
    :rand.seed(:exsss, {42, 42, 42})

    n = @nr_of_points_per_series

    # Generate some (deterministically random)
    x1 = for _i <- 1..n, do: Normal.rand(0.0, 1.0)
    y1 = for x <- x1, do: 2.0 - 0.5 * x + Normal.rand(0.0, 0.2)

    x2 = for _i <- 1..n, do: Normal.rand(0.5, 2.0)
    y2 = for x <- x2, do: 0.2 + 0.85 * x + Normal.rand(0.0, 0.2)

    figure =
      Figure.new([width: Length.cm(9), height: Length.cm(6)], fn _fig ->
        Plot2D.new()
        # Plot the two datasets
        |> Plot2D.draw_scatter_plot(x1, y1, label: "Series 1")
        |> Plot2D.draw_scatter_plot(x2, y2, label: "Series 2")
        # Use typst to explicitly style the title and labels ――――――――――――――――――――――――――――――――
        |> Plot2D.put_title("A. Scatter plot (1 color per dataset)")
        # The axis labels must be explicitly given by the user.
        # One can overwrite default properties such as text rotation.
        # TODO: support non-text based labels
        |> Plot2D.put_axis_label("x", "X-axis")
        |> Plot2D.put_axis_label("y", "Y-axis")
        # Specify lengths using "common" units such as cm or in instead of pt
        |> Plot2D.put_axes_margins(Length.cm(0.2))
        # Manually place the label
        |> Plot2D.put_legend_location(:bottom_right)
        # Always finalize the plot so that it is added to the figure properly.
        |> Plot2D.finalize()
      end)

    Figure.render_to_png_file!(figure, Path.join(dir, "scatter_plot.png"))
  end
end
