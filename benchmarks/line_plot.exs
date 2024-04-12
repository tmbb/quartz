defmodule Quartz.Benchmarks.LinePlot do
  use Dantzig.Polynomial.Operators
  require Quartz.Figure, as: Figure
  alias Quartz.Plot2D
  alias Quartz.Length

  def build_plot() do
    :rand.seed(:exsss, {42, 42, 42})

    figure =
      Figure.new([width: Length.cm(8), height: Length.cm(6), debug: false], fn _fig ->
        # Generate some (deterministically random)
        x = for i <- 1..1000, do: 0.01 * i
        y = for x_i <- x, do: x_i * 0.3 + (0.05 * :rand.uniform())

        _plot =
          Plot2D.new(id: "plot_A")
          |> Plot2D.scatter_plot(x, y)
          # Use typst to explicitly style the title and labels ――――――――――――――――――――――――――――――――
          |> Plot2D.put_title("A. Line plot")
          |> Plot2D.put_axis_label("y", "Prediction: $f(x)$", text: [escape: false])
          |> Plot2D.put_axis_label("x", "Predictor: $x$", text: [escape: false])
          |> Plot2D.finalize()


        byte_size = :erts_debug.size(Figure.get_current_figure())
        IO.puts("figure_size = #{round(byte_size / 1024)}kB")
      end)


    path = Path.join([__DIR__, "line_plot", "example.pdf"])
    Figure.render_to_pdf_file!(figure, path)
  end

  def run_benchee() do
    Benchee.run(%{
      "line_plot" => fn -> build_plot() end
      },
      time: 5,
      memory_time: 3,
      title: "Line plot"
    )
  end

  def run_incendium() do
    Incendium.run(%{
      "line_plot" => fn -> build_plot() end
      },
      time: 5,
      memory_time: 3,
      title: "Line plot"
    )
  end
end

# Quartz.Benchmarks.LinePlot.run_benchee()
Quartz.Benchmarks.LinePlot.build_plot()
