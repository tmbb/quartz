defmodule Quartz.Demo.Miscelaneous.ContourPlot do
  @moduledoc false
  require Quartz.Figure, as: Figure
  alias Quartz.Plot2D
  alias Quartz.Length

  def draw(dir) do
    :rand.seed(:exsss, {42, 42, 42})

    f = fn x, y -> :math.pow(:math.sin(2*x) - :math.cos(1.5*y), 2) end

    isolines = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]

    figure =
      Figure.new([width: Length.cm(8), height: Length.cm(6)], fn _fig ->
        _plot =
          Plot2D.new(id: "plot_A")
          |> Plot2D.draw_function_contour_plot(f, 0.0, :math.pi, 0.0, :math.pi, isolines)
          |> Plot2D.put_title("A. Contour plot for f(𝜃, 𝜑) = (sin(2𝜃) + cos(2𝜑))²")
          |> Plot2D.put_axis_label("y", "𝜃")
          |> Plot2D.put_axis_label("x", "𝜑")
          |> Plot2D.finalize()
      end)

    Figure.render_to_png_file!(figure, Path.join(dir, "contour_plot.png"))
  end
end
