defmodule Quartz.Plot2D.KDEPlotTest do
  use ExUnit.Case, async: true
  import Approval

  require Quartz.Figure, as: Figure
  require Explorer.DataFrame, as: DataFrame

  alias Quartz.Plot2D
  alias Quartz.Length

  test "bernoulli distribution KDE plot (1 chain)" do
    data_path = "test/data/bernoulli_samples.parquet"
    samples = DataFrame.from_parquet!(data_path)

    snapshot = "test/quartz/plot_2d/kde_plot_test/kde_single_snapshot.png"
    reference = "test/quartz/plot_2d/kde_plot_test/kde_single_reference.png"

    theta_1 = DataFrame.filter(samples, chain_id__ == 1)["theta"]

    figure =
      Figure.new([width: Length.cm(8), height: Length.cm(4)], fn _fig ->
        _plot =
          Plot2D.new()
          |> Plot2D.draw_kde_plot(theta_1)
          |> Plot2D.put_axes_margins(Length.cm(0.25))
          |> Plot2D.put_title("A. Probability distribution")
          |> Plot2D.put_axis_label("x", "𝜃")
          |> Plot2D.remove_axis_ticks("y")
          |> Plot2D.finalize()
      end)

    Figure.render_to_png_file!(figure, snapshot)

    approve snapshot: File.read!(snapshot),
            reference: File.read!(reference),
            reviewed: true
  end

  test "plot individual bernoulli distribution KDEs plot (4 chains)" do
    data_path = "test/data/bernoulli_samples.parquet"
    samples = DataFrame.from_parquet!(data_path)

    snapshot = "test/quartz/plot_2d/kde_plot_test/kde_snapshot.png"
    reference = "test/quartz/plot_2d/kde_plot_test/kde_reference.png"

    theta_1 = DataFrame.filter(samples, chain_id__ == 1)["theta"]
    theta_2 = DataFrame.filter(samples, chain_id__ == 2)["theta"]
    theta_3 = DataFrame.filter(samples, chain_id__ == 3)["theta"]
    theta_4 = DataFrame.filter(samples, chain_id__ == 4)["theta"]

    figure =
      Figure.new([width: Length.cm(8), height: Length.cm(4)], fn _fig ->
        _plot =
          Plot2D.new()
          |> Plot2D.draw_kde_plot(theta_1)
          |> Plot2D.draw_kde_plot(theta_2)
          |> Plot2D.draw_kde_plot(theta_3)
          |> Plot2D.draw_kde_plot(theta_4)
          |> Plot2D.put_axes_margins(Length.cm(0.25))
          |> Plot2D.put_title("A. Probability distribution")
          |> Plot2D.put_axis_label("x", "𝜃")
          |> Plot2D.remove_axis_ticks("y")
          |> Plot2D.finalize()
      end)

    Figure.render_to_png_file(figure, snapshot)

    approve snapshot: File.read!(snapshot),
            reference: File.read!(reference),
            reviewed: true
  end

  test "plot grouped bernoulli distributions KDE (4 chains)" do
    data_path = "test/data/bernoulli_samples.parquet"
    samples = DataFrame.from_parquet!(data_path)

    snapshot = "test/quartz/plot_2d/kde_plot_test/kde_grouped_snapshot.png"
    reference = "test/quartz/plot_2d/kde_plot_test/kde_grouped_reference.png"

    figure =
      Figure.new([width: Length.cm(8), height: Length.cm(4)], fn _fig ->
        _plot =
          Plot2D.new()
          |> Plot2D.draw_kde_plot_groups_from_dataframe(samples, "chain_id__", "theta")
          |> Plot2D.put_axes_margins(Length.cm(0.25))
          |> Plot2D.put_title("A. Probability distribution")
          |> Plot2D.put_axis_label("x", "𝜃")
          |> Plot2D.remove_axis_ticks("y")
          |> Plot2D.finalize()
      end)

    Figure.render_to_png_file(figure, snapshot)

    approve snapshot: File.read!(snapshot),
            reference: File.read!(reference),
            reviewed: true
  end
end
