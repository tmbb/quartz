defmodule Quartz.Demo.DistributionPlot.BoxPlot do
  @moduledoc false
  use Dantzig.Polynomial.Operators
  require Quartz.Figure, as: Figure
  require Explorer.DataFrame, as: DataFrame
  alias Quartz.Demo

  alias Quartz.Plot2D
  alias Quartz.Length

  alias Quartz.Plot2D.DistributionPlot

  def draw(dir) do
    data_path = Demo.nuts_chains_path()
    samples = DataFrame.from_parquet!(data_path)

    theta_1 = DataFrame.filter(samples, chain_id__ == 1)["theta"]
    theta_2 = DataFrame.filter(samples, chain_id__ == 2)["theta"]
    theta_3 = DataFrame.filter(samples, chain_id__ == 3)["theta"]
    theta_4 = DataFrame.filter(samples, chain_id__ == 4)["theta"]

    groups = [theta_1, theta_2, theta_3, theta_4]
    labels = ["C1", "C2", "C3", "C4"]

    figure =
      Figure.new([width: Length.cm(8), height: Length.cm(5)], fn _fig ->
        _plot =
          Plot2D.new(id: "plot_A")
          |> DistributionPlot.box_plot(groups, labels: labels)
          # Add some margins to the plot
          |> Plot2D.put_axes_margins(Length.cm(0.25))
          |> Plot2D.put_title("A. Probability distribution")
          |> Plot2D.put_axis_label("x", "𝜃")
          |> Plot2D.put_axis_label("y", "P(𝜃)")
          |> Plot2D.finalize()
      end)


    Demo.example_to_png_and_svg(figure, dir, "line_plot")
  end
end
