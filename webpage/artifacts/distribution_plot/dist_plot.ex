defmodule Quartz.Webpage.Artifacts.DistributionPlot.KDEPlot do
  @moduledoc false
  use Dantzig.Polynomial.Operators
  require Quartz.Figure, as: Figure
  require Explorer.DataFrame, as: DataFrame
  alias Quartz.Webpage.Artifacts

  alias Quartz.Plot2D
  alias Quartz.Length

  def draw(dir) do
    data_path = Artifacts.nuts_chains_path()
    samples = DataFrame.from_parquet!(data_path)

    figure =
      Figure.new([width: Length.cm(8), height: Length.cm(8)], fn _fig ->
        _plot =
          Plot2D.new(id: "plot_A")
          |> Plot2D.draw_kde_plot_groups_from_dataframe(samples, "chain_id__", "theta")
          # Add some margins to the plot
          |> Plot2D.put_axes_margins(Length.cm(0.25))
          |> Plot2D.put_axis_label("x", "𝜃")
          |> Plot2D.put_axis_label("y", "P(𝜃)")
          |> Plot2D.remove_axis_ticks("y")
          |> Plot2D.finalize()
      end)

    Figure.render_to_png_file!(figure, Path.join(dir, "dist_plot.png"))
  end
end
