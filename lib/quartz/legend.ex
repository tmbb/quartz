defmodule Quartz.Legend do
  @moduledoc """
  TODO
  """
  alias Quartz.Sketch
  alias Quartz.Figure
  alias Quartz.Length
  alias Quartz.Plot2D
  alias Quartz.Panel
  alias Quartz.Board
  alias Quartz.LegendSymbolBuilder
  alias Quartz.Text
  alias Quartz.Config

  import Quartz.Operators, only: [algebra: 1]

  require Quartz.Figure, as: Figure

  def symbol_for_color(tag, properties) do
    case tag do
      :rectangle ->
        rectangle_symbol(properties)

      :line ->
        line_symbol(properties)

      :circle ->
        circle_symbol(properties)

      %LegendSymbolBuilder{} = symbol_builder ->
        symbol_builder
    end
  end

  def rectangle_symbol(opts) do
    LegendSymbolBuilder.rectangle(opts)
  end

  def line_symbol(opts) do
    LegendSymbolBuilder.line(opts)
  end

  def circle_symbol(opts) do
    LegendSymbolBuilder.circle(opts)
  end

  defp to_legend_label_text(text) do
    case text do
      %Text{} ->
        text

      bin when is_binary(bin) ->
        Text.new(bin, Config.get_legend_text_attributes())

      other ->
        other
    end
  end

  @doc false
  @spec draw_legend(Plot2D.t()) :: Plot2D.t()
  def draw_legend(%Plot2D{} = plot) do
    draw_vertically_stacked_label(plot)
  end

  @spec draw_vertically_stacked_label(Plot2D.t()) :: Plot2D.t()
  def draw_vertically_stacked_label(%Plot2D{} = plot) do
    legend_items = Enum.reverse(plot.legend_items)

    padding = Length.pt(1.5)
    gap = Length.pt(1.5)

    panels =
      for {{symbol, label}, i} <- Enum.with_index(legend_items) do
        label_sketch = to_legend_label_text(label)
        symbol_sketch = LegendSymbolBuilder.build(symbol, label_sketch, [])

        # Actually draw the sketches
        label_sketch = Sketch.draw(label_sketch)
        symbol_sketch = Sketch.draw(symbol_sketch)

        p_symbol =
          Panel.new(
            left_index: 0,
            top_index: i,
            padding: padding
          )

        p_label =
          Panel.new(
            left_index: 1,
            top_index: i,
            padding: padding,
            padding_left: gap
          )

        Figure.position_with_location_and_alignment(
          symbol_sketch,
          p_symbol.canvas,
          x_alignment: :right,
          x_location: :right,
          y_alignment: :horizon,
          y_location: :horizon,
          contains_vertically?: true,
          contains_horizontally?: true
        )

        Figure.position_with_location_and_alignment(
          label_sketch,
          p_label.canvas,
          x_alignment: :left,
          x_location: :left,
          y_alignment: :top,
          y_location: :top,
          contains_vertically?: true,
          contains_horizontally?: true
        )

        [p_symbol, p_label]
      end

    panels = List.flatten(panels)

    absolute_x_offset = Length.pt(3)
    absolute_y_offset = Length.pt(3)

    legend_board = Board.draw_new(width: 0.0, height: 0.0, panels: panels)

    {y_alignment, x_alignment, y_offset_sign, x_offset_sign} =
      case plot.legend_location do
        :top_left ->
          {:top, :left, 1, 1}

        :top ->
          {:top, :center, 1, 0}

        :top_right ->
          {:top, :right, 1, -1}

        :right ->
          {:horizon, :right, 0, -1}

        :bottom_right ->
          {:bottom, :right, -1, -1}

        :bottom ->
          {:bottom, :center, -1, 0}

        :bottom_left ->
          {:bottom, :left, -1, 1}

        :left ->
          {:horizon, :left, 0, 1}

        _other ->
          {:top, :left, 1, 1}
          raise "Invalid label orientation"
      end

    Figure.position_with_location_and_alignment(
      legend_board,
      plot.data_area,
      x_alignment: x_alignment,
      x_location: x_alignment,
      x_offset: algebra(x_offset_sign * absolute_x_offset),
      y_alignment: y_alignment,
      y_location: y_alignment,
      y_offset: algebra(y_offset_sign * absolute_y_offset)
    )

    plot
  end
end
