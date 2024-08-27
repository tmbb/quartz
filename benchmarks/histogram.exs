defmodule Quartz.Benchmarks.Histogram do
  use Dantzig.Polynomial.Operators
  require Quartz.Figure, as: Figure
  require Explorer.DataFrame, as: DataFrame

  alias Quartz.Plot2D
  alias Quartz.Length

  def build_plot() do
    data_path = Path.join([__DIR__, "data", "samples.parquet"])
    samples = DataFrame.from_parquet!(data_path)

    chain1 = DataFrame.filter(samples, chain_id__ == 1)
    theta1 = chain1[:theta]

    figure =
      Figure.new([width: Length.cm(8), height: Length.cm(4)], fn _fig ->
        _plot =
          Plot2D.new(id: "plot_A")
          |> Plot2D.draw_histogram(theta1)
          # |> Plot2D.box_plot([theta1])
          # Add some margins to the plot
          |> Plot2D.put_axes_margins(Length.cm(0.25))
          |> Plot2D.put_title("A. Probability distributions")
          |> Plot2D.put_axis_label("x", "𝜃")
          |> Plot2D.put_axis_label("y", "P(𝜃)")
          |> Plot2D.finalize()
      end)

    path = Path.join([__DIR__, "histogram", "example.svg"])
    Figure.render_to_svg_file!(figure, path)

    path = Path.join([__DIR__, "histogram", "example.png"])
    Figure.render_to_png_file!(figure, path)
  end

  def run_benchee() do
    Benchee.run(%{
      "box_plot" => fn -> build_plot() end
      },
      time: 5,
      memory_time: 3,
      title: "Histogram"
    )
  end
end

Quartz.Benchmarks.Histogram.build_plot()
