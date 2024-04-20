defmodule Quartz.Benchmarks.ContourPlot do
  # use Dantzig.Polynomial.Operators
  require Quartz.Figure, as: Figure
  alias Quartz.Plot2D
  alias Quartz.Length
  alias Quartz.Circle

  def f(x, y) do
    :math.pow(:math.cos(2*x) - :math.cos(3.4*y), 2)
  end

    alias Quartz.Circle
  alias Quartz.Figure

  def test() do
    fig = Figure.new([width: 20, height: 20], fn _fig ->
      for _i <- 1..10_000 do
        Circle.new(radius: 3.0)
      end

      byte_size = :erts_debug.size(Figure.get_current_figure())
      IO.puts("figure_size = #{round(byte_size / 1024)}kB")
    end)

    fig
  end

  def run_benchee() do
    Benchee.run(%{
      "contour_plot" => fn -> test() end
      },
      time: 5,
      memory_time: 3,
      title: "Contour plot"
    )
  end

  def run_incendium() do
    Incendium.run(%{
      "contour_plot" => fn -> test() end
      },
      time: 5,
      memory_time: 3,
      title: "Contour plot"
    )
  end
end

Quartz.Benchmarks.ContourPlot.test()
# Quartz.Benchmarks.ContourPlot.build_plot()
