defmodule Quartz.Benchmarks.LinePlot do
  use Dantzig.Polynomial.Operators
  require Quartz.Figure, as: Figure
  require Explorer.DataFrame, as: DataFrame

  alias Quartz.Plot2D
  alias Quartz.Length
  alias Quartz.Color.RGB


  def build_plot() do
    data_path = Path.join([__DIR__, "data", "samples.parquet"])
    samples = DataFrame.from_parquet!(data_path)

    theta_1 = DataFrame.filter(samples, chain_id__ == 1)["theta"]
    theta_2 = DataFrame.filter(samples, chain_id__ == 2)["theta"]
    theta_3 = DataFrame.filter(samples, chain_id__ == 3)["theta"]
    theta_4 = DataFrame.filter(samples, chain_id__ == 4)["theta"]

    color_1 = RGB.hot_pink(1.0)
    color_2 = RGB.dark_violet(1.0)
    color_3 = RGB.medium_blue(1.0)
    color_4 = RGB.dark_red(1.0)

    figure =
      Figure.new([width: Length.cm(8), height: Length.cm(6)], fn _fig ->
        _plot =
          Plot2D.new(id: "plot_A")
          |> Plot2D.kde_plot(theta_1, style: [color: color_1])
          |> Plot2D.kde_plot(theta_2, style: [color: color_2])
          |> Plot2D.kde_plot(theta_3, style: [color: color_3])
          |> Plot2D.kde_plot(theta_4, style: [color: color_4])
          # Add some margins to the plot
          |> Plot2D.put_axes_margins(Length.cm(0.25))
          |> Plot2D.put_title("A. Probability distribution")
          |> Plot2D.put_axis_label("x", "𝜃", text: [escape: false])
          |> Plot2D.put_axis_label("y", "P(𝜃)", text: [escape: false])
          |> Plot2D.finalize()
      end)


    path = Path.join([__DIR__, "dist_plot", "example.svg"])
    Figure.render_to_svg_file!(figure, path)
  end

  def run_benchee() do
    Benchee.run(%{
      "line_plot" => fn -> build_plot() end
      },
      time: 5,
      memory_time: 3,
      title: "Line plot"
    )
  end

  def run_incendium() do
    Incendium.run(%{
      "line_plot" => fn -> build_plot() end
      },
      time: 5,
      memory_time: 3,
      title: "Line plot"
    )
  end
end

# Quartz.Benchmarks.LinePlot.run_benchee()
Quartz.Benchmarks.LinePlot.build_plot()
