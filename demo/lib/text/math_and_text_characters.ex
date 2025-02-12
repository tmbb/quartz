defmodule Quartz.Demo.Text.MathAndTextCharacters do
  @moduledoc false

  require Quartz.Figure, as: Figure
  alias Quartz.{Board, Panel, Length, Math, Text, Config}

  def draw(dir) do
    figure =
      Figure.new([width: Length.cm(10), height: Length.cm(4)], fn _fig ->
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
            Text.tspan("C. Free energy will be refered to as "),
            Math.italic_pi(),
            Text.sub(Math.italic_E())
          ], text_attrs)

        sentence4 =
          Text.draw_new([
            Text.tspan("D. For all "),
            Math.italic_n(),
            Text.tspan(" "),
            Math.symbol_in(),
            Text.tspan(" "),
            Math.bb_N(),
            Text.tspan(", "),
            Math.italic_n(),
            Text.tspan(" + 1 "),
            Math.symbol_in(),
            Text.tspan(" "),
            Math.bb_N(),
            Text.tspan(".")
          ], text_attrs |> Keyword.put(:rotation, 10))

        sentences = [
          sentence1,
          sentence2,
          sentence3,
          sentence4
        ]

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

    Figure.render_to_png_file!(figure, Path.join(dir, "math_and_text_characters.png"))
  end
end
