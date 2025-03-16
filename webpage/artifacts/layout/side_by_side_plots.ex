defmodule Quartz.Webpage.Artifacts.Layout.SideBySidePlots do
  @moduledoc false
  use Dantzig.Polynomial.Operators
  require Quartz.Figure, as: Figure
  alias Quartz.Plot2D
  alias Quartz.Length
  alias Quartz.Scale
  alias Quartz.Text
  alias Quartz.Math
  alias Quartz.Config


  def draw(dir) do
    figure =
      Figure.new([width: Length.cm(16), height: Length.cm(6), debug: false], fn _fig ->
        [[bounds_A, bounds_B]] =
          Figure.bounds_for_plots_in_grid(
            nr_of_rows: 1,
            nr_of_columns: 2,
            padding: Length.pt(16)
          )

        x = for z <- 1..900 do 0.02 * z + :rand.uniform() end
        y = for z <- 1..900 do 0.05 * z + :rand.uniform() end

        _plot_task_A =
          Plot2D.new(id: "plot_task_A")
          |> Plot2D.put_bounds(bounds_A)
          |> Plot2D.draw_scatter_plot(x, y)
          |> Plot2D.put_title("A. Task A")
          |> Plot2D.put_axis_label("y", "Y-label (log scale)")
          |> Plot2D.put_axis_scale("y", Scale.log())
          |> Plot2D.put_axis_label("x", "X-axis label (mg/m#super([-2]))", text: [escape: false])
          |> Plot2D.finalize()

        task_B_label = Text.draw_new([
          Text.tspan("X-label with math: "),
          Math.italic_x(),
          Text.sup("2"),
          Text.tspan(" + "),
          Math.italic_y(),
          Text.sup("2"),
          Text.tspan(" (log scale)")
        ], Config.get_axis_label_text_attributes())

        _plot_task_B =
          Plot2D.new(id: "plot_task_B")
          |> Plot2D.put_bounds(bounds_B)
          |> Plot2D.draw_scatter_plot(x, y)
          |> Plot2D.put_title("B. Task B")
          |> Plot2D.put_axis_label("y", "Y-label")
          |> Plot2D.put_axis_label("x", task_B_label)
          |> Plot2D.put_axis_scale("x", Scale.log())
          |> Plot2D.put_axis_scale("y", Scale.log())
          |> Plot2D.finalize()
      end)

    Figure.render_to_png_file!(figure, Path.join(dir, "side_by_side_plots.png"))
  end
end
