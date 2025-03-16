defmodule Quartz.Webpage.Artifacts.DistributionPlot.BoxPlot do
  @moduledoc false
  require Quartz.Figure, as: Figure
  require Explorer.DataFrame, as: DataFrame
  alias Quartz.Webpage.Artifacts

  alias Quartz.Plot2D
  alias Quartz.Length

  alias Quartz.Plot2D.DistributionPlot

  def draw(dir) do
    # Get data from montecarlo simulations
    data_path = Artifacts.nuts_chains_path()
    samples = DataFrame.from_parquet!(data_path)

    # Divide the data in 4 groups (one for each chain)
    theta_1 = DataFrame.filter(samples, chain_id__ == 1)["theta"]
    theta_2 = DataFrame.filter(samples, chain_id__ == 2)["theta"]
    theta_3 = DataFrame.filter(samples, chain_id__ == 3)["theta"]
    theta_4 = DataFrame.filter(samples, chain_id__ == 4)["theta"]

    groups = [theta_1, theta_2, theta_3, theta_4]
    # Label the groups (chains 1 to 4)
    labels = ["C1", "C2", "C3", "C4"]

    figure =
      Figure.new([width: Length.cm(8), height: Length.cm(8)], fn _fig ->
        _plot =
          Plot2D.new()
          |> DistributionPlot.box_plot(groups, labels: labels)
          |> Plot2D.put_axes_margins(Length.cm(0.25))
          |> Plot2D.put_axis_label("x", "𝜃")
          |> Plot2D.put_axis_label("y", "P(𝜃)")
          |> Plot2D.finalize()
      end)

    Figure.render_to_png_file!(figure, Path.join(dir, "box_plot.png"))
  end
end
