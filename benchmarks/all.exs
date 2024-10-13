defmodule Quartz.Benchmarks.All do
  alias Quartz.Demo.{
    Layout,
    DistributionPlot,
    Miscelaneous,
    PairwiseDataPlot
  }

  def run() do
    benchmark_dir = "benchmarks"
    Layout.AspectRatioScatterPlot.draw(benchmark_dir)
    Layout.SideBySidePlots.run_incendium(benchmark_dir)

    PairwiseDataPlot.LinePlot.run_incendium(benchmark_dir)
    PairwiseDataPlot.ScatterPlot.run_incendium(benchmark_dir)

    DistributionPlot.BoxPlot.run_incendium(benchmark_dir)
    DistributionPlot.KDEPlot.run_incendium(benchmark_dir)
    DistributionPlot.Histogram.run_incendium(benchmark_dir)

    Miscelaneous.ContourPlot.run_incendium(benchmark_dir)
  end
end

Quartz.Benchmarks.All.run()
