defmodule Quartz.Plot2D.FunctionContourPlotTest do
  use ExUnit.Case, async: true

  require Quartz.Figure, as: Figure

  alias Quartz.Plot2D
  alias Quartz.Length

  @out_dir Path.join(__DIR__, "function_contour_plot_test")

  def f(x, y) do
    :math.pow(:math.sin(2 * x) - :math.cos(1.5 * y), 2)
  end

  test "contour plot" do
    figure =
      Figure.new([width: Length.cm(8), height: Length.cm(6)], fn _fig ->
        _plot =
          Plot2D.new()
          |> Plot2D.draw_function_contour_plot(&f/2, 0.0, :math.pi(), 0.0, :math.pi(), [
            0.2,
            0.4,
            0.6,
            0.8
          ])
          |> Plot2D.put_title("A. Contour plot for f(𝜃, 𝜑) = (sin(2𝜃) + cos(2𝜑))²")
          # |> Plot2D.put_axes_margins(Length.cm(0.25))
          |> Plot2D.put_axis_label("y", "𝜃")
          |> Plot2D.put_axis_label("x", "𝜑")
          |> Plot2D.finalize()
      end)

    svg_path = Path.join(@out_dir, "contour_1.svg")
    png_path = Path.join(@out_dir, "contour_1.png")

    File.write!(svg_path, Figure.render_to_svg_binary(figure))
    File.write!(png_path, Figure.render_to_png_binary(figure))

    assert Figure.render_to_svg_binary(figure) == File.read!(svg_path)
    assert Figure.render_to_png_binary(figure) == File.read!(png_path)
  end
end
