defmodule Quartz.Benchmarks.ContourPlot do
  # use Dantzig.Polynomial.Operators
  require Quartz.Figure, as: Figure

  def test() do
    fig = Figure.new([width: 20, height: 20], fn _fig ->
      text = Quartz.Text.new("g", font: "Ubuntu", size: 9)

      Figure.assert(text.x == 5)
      Figure.assert(text.y == 10)

      byte_size = :erts_debug.size(Figure.get_current_figure())
      IO.puts("figure_size = #{round(byte_size / 1024)}kB")
    end)

    png_path = Path.join([__DIR__, "test", "example.png"])
    Figure.render_to_png_file!(fig, png_path)
  end
end

Quartz.Benchmarks.ContourPlot.test()
