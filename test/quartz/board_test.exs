defmodule Quartz.BoardTest do
  use ExUnit.Case, async: true

  require Quartz.Figure, as: Figure

  alias Quartz.Length
  alias Quartz.Board
  alias Quartz.Panel
  alias Quartz.Config
  alias Quartz.Text

  def build_label(labelled_items, opts \\ []) do
    padding = Keyword.get(opts, :padding, Length.pt(4))
    gap = Keyword.get(opts, :gap, Length.pt(6))

    panels =
      for {{symbol, label}, i} <- Enum.with_index(labelled_items) do
        p_symbol = Panel.new(left_index: 0, top_index: i, padding: padding)
        p_label = Panel.new(left_index: 1, top_index: i, padding: padding, padding_left: gap)

        Figure.position_with_location_and_alignment(
          symbol,
          p_symbol.canvas,
          x_alignment: :right,
          x_location: :right,
          contains_vertically?: true,
          contains_horizontally?: true
        )

        Figure.position_with_location_and_alignment(
          label,
          p_label.canvas,
          x_alignment: :left,
          x_location: :left,
          contains_vertically?: true,
          contains_horizontally?: true
        )

        [p_symbol, p_label]
      end

    panels = List.flatten(panels)

    Board.new(width: 0.0, height: 0.0, panels: panels)
  end

  test "labeller" do
    figure =
      Figure.new([width: Length.cm(10), height: Length.cm(8), debug: true], fn _fig ->
        text_attrs = Config.get_axis_label_text_attributes()

        build_label([
          {Text.new("X", text_attrs), Text.new("X-factor", text_attrs)},
          {Text.new("Y", text_attrs), Text.new("Y-factor (N=9)", text_attrs)},
          {Text.new("Zzzz", text_attrs), Text.new("Z-factor (N=10)", text_attrs)}
        ])
      end)

    Figure.render_to_svg_file!(figure, "example.svg")
  end

  test "example" do
    figure =
      Figure.new([width: Length.cm(10), height: Length.cm(8), debug: true], fn _fig ->
        p1 =
          Panel.new(
            left_index: 0,
            right_index: 0,
            top_index: 0,
            bottom_index: 0,
            padding: Length.pt(3)
          )

        p2 =
          Panel.new(
            left_index: 1,
            right_index: 1,
            top_index: 0,
            bottom_index: 0,
            padding: Length.pt(3)
          )

        p3 =
          Panel.new(
            left_index: 2,
            right_index: 2,
            top_index: 0,
            bottom_index: 0,
            padding: Length.pt(3)
          )

        p4 =
          Panel.new(
            left_index: 0,
            right_index: 0,
            top_index: 1,
            bottom_index: 1,
            padding: Length.pt(3)
          )

        p5 =
          Panel.new(
            left_index: 1,
            right_index: 1,
            top_index: 1,
            bottom_index: 1,
            padding: Length.pt(3)
          )

        p6 =
          Panel.new(
            left_index: 2,
            right_index: 2,
            top_index: 1,
            bottom_index: 3,
            padding: Length.pt(3)
          )

        panels = [p1, p2, p3, p4, p5, p6]

        text_attrs = Config.get_axis_label_text_attributes()

        Figure.position_with_location_and_alignment(
          Text.new("Panel #1", text_attrs),
          p1.canvas,
          contains_vertically?: true,
          contains_horizontally?: true
        )

        Figure.position_with_location_and_alignment(
          Text.new("Panel #2", text_attrs),
          p2.canvas,
          contains_vertically?: true,
          contains_horizontally?: true
        )

        Figure.position_with_location_and_alignment(
          Text.new("P#4", text_attrs),
          p4.canvas,
          x_location: :left,
          x_alignment: :left,
          contains_vertically?: true,
          contains_horizontally?: true
        )

        Figure.position_with_location_and_alignment(
          Text.new("Panel #5", text_attrs),
          p5.canvas,
          contains_vertically?: true,
          contains_horizontally?: true
        )

        Figure.position_with_location_and_alignment(
          Text.new("Panel #6", text_attrs),
          p6.canvas,
          x_location: :right,
          x_alignment: :right,
          contains_vertically?: true,
          contains_horizontally?: true
        )

        Board.new(
          x: 0,
          y: 0,
          width: 0.0,
          height: 0.0,
          panels: panels
        )
      end)

    Figure.render_to_svg_file!(figure, "example1.svg")
  end
end
