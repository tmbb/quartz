defmodule Quartz.Demo.Text.MathCharactersChart do
  @moduledoc false

  require Quartz.Figure, as: Figure
  import Quartz.Operators, only: [algebra: 1]
  alias Quartz.{Demo, Board, Panel, Length, Math, Text, Config, Sketch}

  def character_table(chars, nr_of_columns) do
    panels =
      for {rows, row_nr} <- Enum.with_index(Enum.chunk_every(chars, nr_of_columns), 0) do
        for {{name, char_sketch}, col_nr} <- Enum.with_index(rows, 0) do
          p_label =
            Panel.new(
              left_index: 3 * col_nr,
              top_index: row_nr,
              padding: Length.pt(4)
            )

          p_arrow =
            Panel.new(
              left_index: 3 * col_nr + 1,
              top_index: row_nr,
              padding: Length.pt(4)
            )

          p_char =
            Panel.new(
              left_index: 3 * col_nr + 2,
              top_index: row_nr,
              padding: Length.pt(4),
              padding_right: Length.pt(14)
            )

          text_attrs =
            Config.get_major_tick_label_text_attributes(
              family: "Ubuntu Mono",
              size: 10
            )

          Figure.position_with_location_and_alignment(
            Text.draw_new("#{name}()", text_attrs),
            p_label.canvas,
            x_alignment: :left,
            x_location: :left,
            y_alignment: :bottom,
            y_location: :bottom,
            contains_vertically?: true,
            contains_horizontally?: true
          )

          Figure.position_with_location_and_alignment(
            Text.draw_new("→", text_attrs),
            p_arrow.canvas,
            x_alignment: :center,
            x_location: :center,
            y_alignment: :bottom,
            y_location: :bottom,
            contains_vertically?: true,
            contains_horizontally?: true
          )

          Figure.position_with_location_and_alignment(
            Text.draw_new(char_sketch),
            p_char.canvas,
            x_alignment: :left,
            x_location: :left,
            y_alignment: :bottom,
            y_location: :bottom,
            contains_vertically?: true,
            contains_horizontally?: true
          )

          [p_label, p_arrow, p_char]
        end
      end

    Board.draw_new(
      panels: List.flatten(panels)
    )
  end

  def draw(dir) do
    figure =
      Figure.new([height: Length.cm(50), width: Length.cm(16)], fn fig ->
        opts = [font: "Linux Libertine", size: 14]

        data = [
          {Math.mathematical_italic_sketches(opts), 4},
          {Math.mathematical_double_struck_sketches(opts), 6},
          {Math.mathematical_fraktur_sketches(opts), 5},
          {Math.mathematical_script_sketches(opts), 5},
          {Math.mathematical_bold_sketches(opts), 4},
          {Math.mathematical_bold_italic_sketches(opts), 3},
          {Math.mathematical_bold_script_sketches(opts), 3},
          {Math.mathematical_monospace_sketches(opts), 5},
          {Math.mathematical_sans_serif_bold_italic_sketches(opts), 3},
          {Math.mathematical_sans_serif_bold_sketches(opts), 4},
          {Math.mathematical_sans_serif_italic_sketches(opts), 4},
          {Math.mathematical_sans_serif_sketches(opts), 5}
        ]

        final_y =
          Enum.reduce(data, Length.pt(4), fn {{category, sketches}, nr_of_columns}, y ->
            title = Text.draw_new(category.unicode, Config.get_plot_title_text_attributes(size: 18))
            table = character_table(sketches, nr_of_columns)

            Figure.assert(Sketch.bbox_top(title) == y + Length.pt(5))
            Figure.assert(title.x == Length.pt(16))

            y_table = algebra(y + Sketch.bbox_height(title) + Length.pt(16))

            Figure.assert(Sketch.bbox_top(table) == y_table)
            Figure.assert(Sketch.bbox_left(table) == Length.pt(4))


            Figure.assert(fig.width >= Sketch.bbox_right(table) + Length.pt(4))

            _new_y = algebra(y_table + Sketch.bbox_height(table) + Length.pt(20))
          end)

        Figure.assert(fig.height >= final_y)
      end)

    Demo.example_to_png_and_svg(figure, dir, "math_characters_chart")
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
