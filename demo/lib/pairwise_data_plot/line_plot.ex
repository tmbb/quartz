defmodule Quartz.Demo.PairwiseDataPlot.LinePlot do
  @moduledoc false
  use Dantzig.Polynomial.Operators
  require Quartz.Figure, as: Figure
  alias Quartz.Plot2D
  alias Quartz.Length
  alias Quartz.Color.RGB

  def draw(dir) do
    :rand.seed(:exsss, {42, 42, 42})

    figure =
      Figure.new([width: Length.cm(8), height: Length.cm(6), debug: false], fn _fig ->
        # Generate some (deterministically random)
        x = for _i <- 1..200, do: :rand.uniform()
        y = for _i <- 1..200, do: :rand.uniform()

        _plot =
          Plot2D.new(id: "plot_A")
          |> Plot2D.draw_scatter_plot(x, y, style: [color: RGB.teal(0.5)])
          # Use typst to explicitly style the title and labels ――――――――――――――――――――――――――――――――
          |> Plot2D.put_title("A. Line plot")
          |> Plot2D.put_axis_label("y", "f(x)", text: [escape: false, rotation: 0])
          |> Plot2D.put_axis_label("x", "Predictor: x", text: [escape: false])
          |> Plot2D.put_axes_margins(Length.cm(0.25))
          |> Plot2D.finalize()
      end)

    Figure.render_to_png_file!(figure, Path.join(dir, "line_plot.png"))
  end
end
