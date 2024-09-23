defmodule Quartz.Demo.DistributionPlot.KDEPlot do
  @moduledoc false
  use Dantzig.Polynomial.Operators
  require Quartz.Figure, as: Figure
  require Explorer.DataFrame, as: DataFrame
  alias Quartz.Demo

  alias Quartz.Plot2D
  alias Quartz.Length

  def draw(dir) do
    data_path = Demo.nuts_chains_path()
    samples = DataFrame.from_parquet!(data_path)

    figure =
      Figure.new([width: Length.cm(8), height: Length.cm(4)], fn _fig ->
        _plot =
          Plot2D.new(id: "plot_A")
          |> Plot2D.draw_kde_plot_groups_from_dataframe(samples, "chain_id__", "theta")
          # Add some margins to the plot
          |> Plot2D.put_axes_margins(Length.cm(0.25))
          |> Plot2D.put_title("A. Probability distributions")
          |> Plot2D.put_axis_label("x", "𝜃")
          |> Plot2D.put_axis_label("y", "P(𝜃)")
          |> Plot2D.remove_axis_ticks("y")
          |> Plot2D.finalize()
      end)


    Demo.example_to_png_and_svg(figure, dir, "dist_plot")
  end

  def run_incendium(dir) do
    Incendium.run(%{
      "kde_plot" => fn -> draw(dir) end
      },
      time: 5,
      memory_time: 3,
      title: "KDE plot"
    )
  end
end
