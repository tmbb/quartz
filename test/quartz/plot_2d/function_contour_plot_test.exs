defmodule Quartz.Plot2D.FunctionContourPlotTest do
  use ExUnit.Case, async: true
  import Approval

  require Quartz.Figure, as: Figure

  alias Quartz.Plot2D
  alias Quartz.Length

  @out_dir Path.join(__DIR__, "function_contour_plot_test")

  def f(x, y) do
    :math.pow(:math.sin(2 * x) - :math.cos(1.5 * y), 2)
  end

  test "contour plot" do
    levels = for i <- 0..20, do: (i - 10) * 0.4

    snapshot = Path.join(@out_dir, "countour_1_snapshot.png")
    reference = Path.join(@out_dir, "countour_1_reference.png")

    figure =
      Figure.new([width: Length.cm(8), height: Length.cm(6)], fn _fig ->
        _plot =
          Plot2D.new()
          |> Plot2D.draw_function_contour_plot(&f/2, 0.0, :math.pi(), 0.0, :math.pi(), levels)
          |> Plot2D.put_title("A. Contour plot for f(𝜃, 𝜑) = (sin(2𝜃) + cos(2𝜑))²")
          |> Plot2D.put_axis_label("y", "𝜃")
          |> Plot2D.put_axis_label("x", "𝜑")
          |> Plot2D.finalize()
      end)

    Figure.render_to_png_file(figure, snapshot)

    approve snapshot: File.read!(snapshot),
            reference: File.read!(reference),
            reviewed: true
  end
end
