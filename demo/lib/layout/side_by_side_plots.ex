defmodule Quartz.Demo.Layout.SideBySidePlots do
  @moduledoc false
  use Dantzig.Polynomial.Operators
  require Quartz.Figure, as: Figure
  alias Quartz.Plot2D
  alias Quartz.Length
  alias Quartz.Scale
  alias Quartz.Demo

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

        _plot_task_B =
          Plot2D.new(id: "plot_task_B")
          |> Plot2D.put_bounds(bounds_B)
          |> Plot2D.draw_scatter_plot(x, y)
          |> Plot2D.put_title("B. Task B")
          |> Plot2D.put_axis_label("y", "Y-label")
          |> Plot2D.put_axis_label("x", "X-label (with  math: $x^2 + y^2$)", text: [escape: false])
          |> Plot2D.put_axis_scale("x", Scale.log())
          |> Plot2D.put_axis_scale("y", Scale.log())
          |> Plot2D.finalize()
      end)

    Demo.example_to_png_and_svg(figure, dir, "side_by_side_plots")
  end

  def run_incendium(dir) do
    Incendium.run(%{
      "pair_of_plots" => fn -> draw(dir) end
    },
    title: "Side by side plots")
  end
end
