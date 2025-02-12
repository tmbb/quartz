defmodule Quartz.Demo do
  # Extract the height and width from the SVG file
  insert_png_image = fn name ->
    ~s[<img width="75%" src="assets/#{name}.png"/>]
  end

  @moduledoc """

  ## Pairwise data plots

  ### Scatter plot examples

  Simple scatter plot:

  #{insert_png_image.("scatter_plot")}

  Simple line plot:

  #{insert_png_image.("line_plot")}

  ## Distribution plots

  ### KDE plot examples

  #{insert_png_image.("dist_plot")}

  ### Histogram

  #{insert_png_image.("histogram")}

  ## Layout examples

  Side by side plot, showing the use of different scales:

  #{insert_png_image.("side_by_side_plots")}

  ## Gridded data

  ### Countour plot

  Contour of a function

  #{insert_png_image.("contour_plot")}

  ## Text and math support

  Mix between normal text characters and math characters:

  #{insert_png_image.("math_and_text_characters")}

  Full list of supported symbols:

  #{insert_png_image.("math_characters_chart")}
  """

  alias Quartz.Figure

  @doc false
  def example_to_png_and_svg(figure, dir, subdir) do
    File.mkdir_p!(Path.join(dir, subdir))

    svg_path = Path.join([dir, subdir, "example.svg"])
    Figure.render_to_svg_file!(figure, svg_path)

    png_path = Path.join([dir, subdir, "example.png"])
    Figure.render_to_png_file!(figure, png_path)

    :ok
  end

  @doc false
  def nuts_chains_path() do
    Path.join([:code.priv_dir(:quartz), "demo", "samples.parquet"])
  end

  alias Quartz.Figure
  alias Quartz.Demo.{
    Layout,
    DistributionPlot,
    Miscelaneous,
    PairwiseDataPlot,
    Text
  }

  @doc false
  def draw_demo_plots(demo_dir) do
    # Layout.AspectRatioScatterPlot.draw(demo_dir)
    Layout.SideBySidePlots.draw(demo_dir)

    PairwiseDataPlot.LinePlot.draw(demo_dir)
    PairwiseDataPlot.ScatterPlot.draw(demo_dir)

    DistributionPlot.BoxPlot.draw(demo_dir)
    DistributionPlot.KDEPlot.draw(demo_dir)
    DistributionPlot.Histogram.draw(demo_dir)

    Miscelaneous.ContourPlot.draw(demo_dir)

    Text.MathCharactersChart.draw(demo_dir)
    Text.MathAndTextCharacters.draw(demo_dir)
  end
end
