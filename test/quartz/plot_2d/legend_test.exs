defmodule Quartz.Test.Plot2D.LegendTest do
  use ExUnit.Case, async: true
  import Approval

  alias Quartz.Figure
  alias Quartz.Plot2D
  alias Quartz.Length

  alias Statistics.Distributions.Normal

  @nr_of_points_per_series 60

  def example_data() do
    :rand.seed(:exsss, {42, 42, 42})
    n = @nr_of_points_per_series

    # Generate some (deterministically random)
    x1 = for _i <- 1..n, do: Normal.rand(0.0, 1.0)
    y1 = for x <- x1, do: 1.0 - 0.9 * x + Normal.rand(0.0, 0.4)

    x2 = for _i <- 1..n, do: Normal.rand(0.5, 2.0)
    y2 = for x <- x2, do: 0.2 + 0.85 * x + Normal.rand(0.0, 0.4)

    %{x1: x1, y1: y1, x2: x2, y2: y2}
  end

  def simple_non_finalized_plot(data) do
    %{x1: x1, y1: y1, x2: x2, y2: y2} = data

    Plot2D.new()
    |> Plot2D.draw_scatter_plot(x1, y1, label: "Series 1", style: [opacity: 0.5])
    |> Plot2D.draw_scatter_plot(x2, y2, label: "Series 1", style: [opacity: 0.5])
    |> Plot2D.put_title("A. Legend test")
    |> Plot2D.put_axes_margins(Length.cm(0.2))
  end

  test "default legend location" do
    snapshot = Path.join(__DIR__, "legend_test_outputs/default_legend_location_snapshot.png")
    reference = Path.join(__DIR__, "legend_test_outputs/default_legend_location_reference.png")
    # Deterministic simmulated data
    data = example_data()

    figure =
      Figure.new([width: Length.cm(6), height: Length.cm(5)], fn _fig ->
        data
        |> simple_non_finalized_plot()
        |> Plot2D.finalize()
      end)

    Figure.render_to_png_file!(figure, snapshot)

    approve snapshot: File.read!(snapshot),
            reference: File.read!(reference),
            reviewed: true
  end

  test "top left location" do
    snapshot = Path.join(__DIR__, "legend_test_outputs/top_left_legend_location_snapshot.png")
    reference = Path.join(__DIR__, "legend_test_outputs/top_left_legend_location_reference.png")
    # Deterministic simmulated data
    data = example_data()

    figure =
      Figure.new([width: Length.cm(6), height: Length.cm(5)], fn _fig ->
        data
        |> simple_non_finalized_plot()
        |> Plot2D.put_legend_location(:top_left)
        |> Plot2D.finalize()
      end)

    Figure.render_to_png_file!(figure, snapshot)

    approve snapshot: File.read!(snapshot),
            reference: File.read!(reference),
            reviewed: true
  end

  test "top location" do
    snapshot = Path.join(__DIR__, "legend_test_outputs/top_legend_location_snapshot.png")
    reference = Path.join(__DIR__, "legend_test_outputs/top_legend_location_reference.png")
    # Deterministic simmulated data
    data = example_data()

    figure =
      Figure.new([width: Length.cm(6), height: Length.cm(5)], fn _fig ->
        data
        |> simple_non_finalized_plot()
        |> Plot2D.put_legend_location(:top)
        |> Plot2D.finalize()
      end)

    Figure.render_to_png_file!(figure, snapshot)

    approve snapshot: File.read!(snapshot),
            reference: File.read!(reference),
            reviewed: true
  end

  test "top right location" do
    snapshot = Path.join(__DIR__, "legend_test_outputs/top_right_legend_location_snapshot.png")
    reference = Path.join(__DIR__, "legend_test_outputs/top_right_legend_location_reference.png")
    # Deterministic simmulated data
    data = example_data()

    figure =
      Figure.new([width: Length.cm(6), height: Length.cm(5)], fn _fig ->
        data
        |> simple_non_finalized_plot()
        |> Plot2D.put_legend_location(:top_right)
        |> Plot2D.finalize()
      end)

    Figure.render_to_png_file!(figure, snapshot)

    approve snapshot: File.read!(snapshot),
            reference: File.read!(reference),
            reviewed: true
  end

  test "right location" do
    snapshot = Path.join(__DIR__, "legend_test_outputs/right_legend_location_snapshot.png")
    reference = Path.join(__DIR__, "legend_test_outputs/right_legend_location_reference.png")
    # Deterministic simmulated data
    data = example_data()

    figure =
      Figure.new([width: Length.cm(6), height: Length.cm(5)], fn _fig ->
        data
        |> simple_non_finalized_plot()
        |> Plot2D.put_legend_location(:right)
        |> Plot2D.finalize()
      end)

    Figure.render_to_png_file!(figure, snapshot)

    approve snapshot: File.read!(snapshot),
            reference: File.read!(reference),
            reviewed: true
  end

  test "bottom right location" do
    snapshot = Path.join(__DIR__, "legend_test_outputs/bottom_right_legend_location_snapshot.png")
    reference = Path.join(__DIR__, "legend_test_outputs/bottom_right_legend_location_reference.png")
    # Deterministic simmulated data
    data = example_data()

    figure =
      Figure.new([width: Length.cm(6), height: Length.cm(5)], fn _fig ->
        data
        |> simple_non_finalized_plot()
        |> Plot2D.put_legend_location(:bottom_right)
        |> Plot2D.finalize()
      end)

    Figure.render_to_png_file!(figure, snapshot)

    approve snapshot: File.read!(snapshot),
            reference: File.read!(reference),
            reviewed: true
  end

  test "bottom location" do
    snapshot = Path.join(__DIR__, "legend_test_outputs/bottom_legend_location_snapshot.png")
    reference = Path.join(__DIR__, "legend_test_outputs/bottom_legend_location_reference.png")
    # Deterministic simmulated data
    data = example_data()

    figure =
      Figure.new([width: Length.cm(6), height: Length.cm(5)], fn _fig ->
        data
        |> simple_non_finalized_plot()
        |> Plot2D.put_legend_location(:bottom)
        |> Plot2D.finalize()
      end)

    Figure.render_to_png_file!(figure, snapshot)

    approve snapshot: File.read!(snapshot),
            reference: File.read!(reference),
            reviewed: true
  end

  test "bottom left location" do
    snapshot = Path.join(__DIR__, "legend_test_outputs/bottom_left_legend_location_snapshot.png")
    reference = Path.join(__DIR__, "legend_test_outputs/bottom_left_legend_location_reference.png")
    # Deterministic simmulated data
    data = example_data()

    figure =
      Figure.new([width: Length.cm(6), height: Length.cm(5)], fn _fig ->
        data
        |> simple_non_finalized_plot()
        |> Plot2D.put_legend_location(:bottom_left)
        |> Plot2D.finalize()
      end)

    Figure.render_to_png_file!(figure, snapshot)

    approve snapshot: File.read!(snapshot),
            reference: File.read!(reference),
            reviewed: true
  end

  test "left location" do
    snapshot = Path.join(__DIR__, "legend_test_outputs/left_legend_location_snapshot.png")
    reference = Path.join(__DIR__, "legend_test_outputs/left_legend_location_reference.png")
    # Deterministic simmulated data
    data = example_data()

    figure =
      Figure.new([width: Length.cm(6), height: Length.cm(5)], fn _fig ->
        data
        |> simple_non_finalized_plot()
        |> Plot2D.put_legend_location(:left)
        |> Plot2D.finalize()
      end)

    Figure.render_to_png_file!(figure, snapshot)

    approve snapshot: File.read!(snapshot),
            reference: File.read!(reference),
            reviewed: true
  end
end
