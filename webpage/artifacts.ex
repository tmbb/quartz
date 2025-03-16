defmodule Quartz.Webpage.Artifacts do
  @doc false
  def nuts_chains_path() do
    "webpage/data/samples.parquet"
  end

  alias Quartz.Webpage.Artifacts.{
    Layout,
    DistributionPlot,
    Miscelaneous,
    PairwiseDataPlot,
    Text
  }

  def run(dir) do
    # Layout.AspectRatioScatterPlot.draw(dir)
    Layout.SideBySidePlots.draw(dir)

    PairwiseDataPlot.LinePlot.draw(dir)
    PairwiseDataPlot.ScatterPlot.draw(dir)

    DistributionPlot.BoxPlot.draw(dir)
    DistributionPlot.KDEPlot.draw(dir)
    DistributionPlot.Histogram.draw(dir)

    Miscelaneous.ContourPlot.draw(dir)

    Text.MathCharactersChart.draw(dir)
    # Text.MathAndTextCharacters.draw(dir)
  end
end
