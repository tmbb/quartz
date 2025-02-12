defmodule Quartz.Demo.DistributionPlot.Histogram do
  @moduledoc false
  require Explorer.DataFrame, as: DataFrame

  use Quartz.Operators
  require Quartz.Figure, as: Figure
  alias Quartz.Demo
  alias Quartz.Plot2D
  alias Quartz.Length

  def draw(dir) do
    data_path = Demo.nuts_chains_path()
    samples = DataFrame.from_parquet!(data_path)

    chain1 = DataFrame.filter(samples, chain_id__ == 1)
    theta1 = chain1[:theta]

    figure =
      Figure.new([width: Length.cm(8), height: Length.cm(4)], fn _fig ->
        _plot =
          Plot2D.new(id: "plot_A")
          |> Plot2D.draw_histogram(theta1)
          # Add some margins to the plot
          |> Plot2D.put_axes_margins(Length.cm(0.25))
          |> Plot2D.put_title("A. Probability distributions")
          |> Plot2D.put_axis_label("x", "𝜃")
          |> Plot2D.put_axis_label("y", "P(𝜃)")
          |> Plot2D.finalize()
      end)

    Figure.render_to_png_file!(figure, Path.join(dir, "histogram.png"))
  end
end
