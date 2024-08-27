defmodule Quartz.Benchmarks.ContourPlot do
  # use Dantzig.Polynomial.Operators
  require Quartz.Figure, as: Figure
  alias Quartz.Plot2D
  alias Quartz.Length

  def f(x, y) do
    :math.pow(:math.sin(2*x) - :math.cos(1.5*y), 2)
  end

  def build_plot() do
    :rand.seed(:exsss, {42, 42, 42})

    figure =
      Figure.new([width: Length.cm(8), height: Length.cm(6)], fn _fig ->
        _plot =
          Plot2D.new(id: "plot_A")
          |> Plot2D.draw_function_contour_plot(&f/2, 0.0, :math.pi, 0.0, :math.pi, [0.2, 0.4, 0.6, 0.8])
          |> Plot2D.put_title("A. Contour plot for f(𝜃, 𝜑) = (sin(2𝜃) + cos(2𝜑))²")
          |> Plot2D.put_axis_label("y", "𝜃")
          |> Plot2D.put_axis_label("x", "𝜑")
          |> Plot2D.finalize()
      end)


    svg_path = Path.join([__DIR__, "contour_plot", "example.svg"])
    Figure.render_to_svg_file!(figure, svg_path)

    path = Path.join([__DIR__, "contour_plot", "example.png"])
    Figure.render_to_png_file!(figure, path)
  end

  def run_benchee() do
    Benchee.run(%{
      "draw_line_plot" => fn -> build_plot() end
      },
      time: 5,
      memory_time: 3,
      title: "Line plot"
    )
  end

  # def run_incendium() do
  #   Incendium.run(%{
  #     "draw_line_plot" => fn -> build_plot() end
  #     },
  #     time: 5,
  #     memory_time: 3,
  #     title: "Line plot"
  #   )
  # end
end

# Quartz.Benchmarks.ContourPlot.run_benchee()
Quartz.Benchmarks.ContourPlot.build_plot()
