defmodule Quartz.Panel do
  @moduledoc false

  alias Quartz.Canvas
  require Quartz.KeywordSpec, as: KeywordSpec

  @default_padding 0

  defstruct left_index: nil,
            top_index: nil,
            right_index: nil,
            bottom_index: nil,
            padding_top: nil,
            padding_bottom: nil,
            padding_left: nil,
            padding_right: nil,
            background_fill: nil,
            canvas: nil

  defp first_non_nil([]), do: nil

  defp first_non_nil([x | xs]) do
    if x do
      x
    else
      first_non_nil(xs)
    end
  end

  def new(attrs) do
    KeywordSpec.validate!(attrs, [
      !left_index,
      !top_index,
      right_index: left_index,
      bottom_index: top_index,
      padding: nil,
      padding_top: nil,
      padding_bottom: nil,
      padding_left: nil,
      padding_right: nil,
      background_fill: nil,
      canvas: Canvas.draw_new()
    ])

    padding_top = first_non_nil([padding_top, padding, @default_padding])
    padding_bottom = first_non_nil([padding_bottom, padding, @default_padding])
    padding_left = first_non_nil([padding_left, padding, @default_padding])
    padding_right = first_non_nil([padding_right, padding, @default_padding])

    new_attrs = [
      left_index: left_index,
      top_index: top_index,
      right_index: right_index,
      bottom_index: bottom_index,
      padding_top: padding_top,
      padding_bottom: padding_bottom,
      padding_left: padding_left,
      padding_right: padding_right,
      background_fill: background_fill,
      canvas: canvas
    ]

    struct(__MODULE__, new_attrs)
  end
end
