defmodule Quartz.Benchmarks.KDEPlot do
  use Dantzig.Polynomial.Operators
  require Quartz.Figure, as: Figure
  require Explorer.DataFrame, as: DataFrame

  alias Quartz.Plot2D
  alias Quartz.Length

  def build_plot() do
    data_path = Path.join([__DIR__, "data", "samples.parquet"])
    samples = DataFrame.from_parquet!(data_path)

    figure =
      Figure.new([width: Length.cm(8), height: Length.cm(4)], fn _fig ->
        _plot =
          Plot2D.new(id: "plot_A")
          |> Plot2D.kde_plot_groups_from_dataframe(samples, "chain_id__", "theta")
          # Add some margins to the plot
          |> Plot2D.put_axes_margins(Length.cm(0.25))
          |> Plot2D.put_title("A. Probability distributions")
          |> Plot2D.put_axis_label("x", "𝜃")
          |> Plot2D.put_axis_label("y", "P(𝜃)")
          |> Plot2D.remove_axis_ticks("y")
          |> Plot2D.finalize()
      end)

    path = Path.join([__DIR__, "dist_plot", "example.svg"])
    Figure.render_to_svg_file!(figure, path)

    path = Path.join([__DIR__, "dist_plot", "example.png"])
    Figure.render_to_png_file!(figure, path)
  end

  def run_benchee() do
    Benchee.run(%{
      "box_plot" => fn -> build_plot() end
      },
      time: 5,
      memory_time: 3,
      title: "Box plot"
    )
  end

  def run_incendium() do
    Incendium.run(%{
      "kde_plot" => fn -> build_plot() end
      },
      time: 5,
      memory_time: 3,
      title: "KDE plot"
    )
  end
end

# Quartz.Benchmarks.LinePlot.run_benchee()
Quartz.Benchmarks.KDEPlot.build_plot()
