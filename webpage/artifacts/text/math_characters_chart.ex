defmodule Quartz.Webpage.Artifacts.Text.MathCharactersChart do
  @moduledoc false

  require Quartz.Figure, as: Figure
  import Quartz.Operators, only: [algebra: 1]
  alias Quartz.{Board, Panel, Length, Math, Text, Config, Sketch}

  def character_table_with_title(fig, y, category, sketches, nr_of_columns) do
    title = Text.draw_new(category.unicode, Config.get_plot_title_text_attributes(size: 18))
    table = character_table(sketches, nr_of_columns)

    Figure.assert(Sketch.bbox_top(title) == y + Length.pt(5))
    Figure.assert(title.x == Length.pt(16))

    y_table = algebra(y + Sketch.bbox_height(title) + Length.pt(16))

    Figure.assert(Sketch.bbox_top(table) == y_table)
    Figure.assert(Sketch.bbox_left(table) == Length.pt(4))

    Figure.assert(fig.width >= Sketch.bbox_right(table) + Length.pt(4))

    _new_y = algebra(y_table + Sketch.bbox_height(table) + Length.pt(20))
  end

  def character_table(chars, nr_of_columns) do
    panels =
      for {rows, row_nr} <- Enum.with_index(Enum.chunk_every(chars, nr_of_columns), 0) do
        for {{name, char_sketch}, col_nr} <- Enum.with_index(rows, 0)
         do
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
              padding: Length.pt(4)
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
            y_alignment: :horizon,
            y_location: :horizon,
            contains_vertically?: true,
            contains_horizontally?: true
          )

          Figure.position_with_location_and_alignment(
            Text.draw_new("→", text_attrs),
            p_arrow.canvas,
            x_alignment: :center,
            x_location: :center,
            y_alignment: :horizon,
            y_location: :horizon,
            contains_vertically?: true,
            contains_horizontally?: true
          )

          Figure.position_with_location_and_alignment(
            Text.draw_new(char_sketch),
            p_char.canvas,
            x_alignment: :left,
            x_location: :left,
            y_alignment: :horizon,
            y_location: :horizon,
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

  def draw_category(dir, {artist, nr_of_columns}) do
    figure = Figure.new([height: Length.cm(0), width: Length.cm(0)], fn fig ->
      {category, sketches} = artist.()
      final_y = character_table_with_title(fig, Length.pt(4), category, sketches, nr_of_columns)

      Figure.assert(fig.height >= final_y)
    end)

    # Dummy figure so that we can get the category title...
    _dummy_figure = Figure.new([], fn _fig ->
      {category, _} = artist.()
      Figure.render_to_png_file!(figure, Path.join(dir, "#{category.slug}.png"))
    end)
  end

  def draw(dir) do
    opts = [size: 14]

    # Lazy loading of categories because they must be inside a figure context
    categories = [
        {fn -> Math.mathematical_italic_sketches(opts) end, 4},
        {fn -> Math.mathematical_symbol_sketches(opts) end, 2},
        {fn -> Math.mathematical_double_struck_sketches(opts) end, 6},
        {fn -> Math.mathematical_fraktur_sketches(opts) end, 5},
        {fn -> Math.mathematical_script_sketches(opts) end, 5},
        {fn -> Math.mathematical_bold_sketches(opts) end, 4},
        {fn -> Math.mathematical_bold_italic_sketches(opts) end, 3},
        {fn -> Math.mathematical_bold_script_sketches(opts) end, 3},
        {fn -> Math.mathematical_monospace_sketches(opts) end, 5},
        {fn -> Math.mathematical_sans_serif_bold_italic_sketches(opts) end, 3},
        {fn -> Math.mathematical_sans_serif_bold_sketches(opts) end, 4},
        {fn -> Math.mathematical_sans_serif_italic_sketches(opts) end, 4},
        {fn -> Math.mathematical_sans_serif_sketches(opts) end, 5}
      ]

    for category <- categories do
      draw_category(Path.join(dir, "math_characters"), category)
    end

    :ok
  end
end
