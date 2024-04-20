defmodule Quartz.Benchmarks.ContourPlot do
  # use Dantzig.Polynomial.Operators
  require Quartz.Figure, as: Figure
  alias Quartz.Plot2D
  alias Quartz.Length

  def f(x, y) do
    :math.pow(:math.cos(2*x) - :math.cos(3.4*y), 2)
  end

  def build_plot() do
    :rand.seed(:exsss, {42, 42, 42})

    figure =
      Figure.new([width: Length.cm(8), height: Length.cm(6), debug: false], fn _fig ->
        _plot =
          Plot2D.new(id: "plot_A")
          |> Plot2D.draw_function_contour_plot(&f/2, 0.0, :math.pi, 0.0, :math.pi, [0.2, 0.4, 0.6, 0.8])
          |> Plot2D.put_title("A. Contour plot for $f(theta, phi) = (cos(2 theta) + cos(2 phi))^2$", text: [escape: false])
          |> Plot2D.put_axis_label("y", "$phi$", text: [escape: false])
          |> Plot2D.put_axis_label("x", "$theta$", text: [escape: false])
          |> Plot2D.finalize()
      end)


    # path = Path.join([__DIR__, "contour_plot", "example.pdf"])
    # Figure.render_to_pdf_file!(figure, path)
  end

  def run_benchee() do
    Benchee.run(%{
      "line_plot" => fn -> build_plot() end
      },
      time: 5,
      memory_time: 3,
      title: "Line plot"
    )
  end

  def run_incendium() do
    Incendium.run(%{
      "line_plot" => fn -> build_plot() end
      },
      time: 5,
      memory_time: 3,
      title: "Line plot"
    )
  end
end

# Quartz.Benchmarks.ContourPlot.run_benchee()
Quartz.Benchmarks.ContourPlot.build_plot()
