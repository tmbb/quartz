defmodule Quartz.Demo.Text.MathAndTextCharacters do
  @moduledoc false

  require Quartz.Figure, as: Figure
  alias Quartz.{Demo, Board, Panel, Length, Math, Text, Config, Sketch}

  def draw(dir) do
    figure =
      Figure.new([width: Length.cm(10), height: Length.cm(2), debug: true], fn _fig ->
        text_attrs = Config.get_legend_text_attributes(size: 10)

        sentence1 =
          Text.draw_new([
            Text.tspan("A. The most beautiful formula: "),
            Math.italic_e(),
            Text.sup([Math.italic_i(), Math.italic_pi()]),
            " + 1 = 0"
          ], text_attrs)

        sentence2 =
          Text.draw_new([
            "B. Pythagoras discovered that ",
            Math.italic_a(),
            Text.sup("2"),
            " + ",
            Math.italic_b(),
            Text.sup("2"),
            " = ",
            Math.italic_c(),
            Text.sup("2")
          ], text_attrs)

        sentence3 =
          Text.draw_new([
            Text.tspan("C. "),
            Math.italic_pi(),
            Text.sub(Math.italic_E())
          ], text_attrs)

        sentences = [
          sentence1,
          sentence2,
          sentence3
        ]

        # Figure.assert(Sketch.bbox_top(sentence1) == Length.pt(12))

        panels =
          for {sentence, i} <- Enum.with_index(sentences, 0) do
            panel = Panel.new(left_index: 0, top_index: i, padding: Length.pt(5))

            Figure.position_with_location_and_alignment(
              sentence,
              panel.canvas,
              x_alignment: :left,
              x_location: :left,
              y_alignment: :horizon,
              y_location: :horizon,
              contains_vertically?: true,
              contains_horizontally?: true
            )

            panel
        end

        Board.draw_new(x: 0, y: 0, height: 0, width: 0, panels: panels)
      end)

    Demo.example_to_png_and_svg(figure, dir, "math_and_text_characters")
  end

  def run_incendium(dir) do
    Incendium.run(%{
      "scatter_plot" => fn -> draw(dir) end
      },
      time: 5,
      memory_time: 3,
      title: "Scatter plot"
    )
  end
end
