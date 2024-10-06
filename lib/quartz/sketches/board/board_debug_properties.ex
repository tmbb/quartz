defmodule Quartz.Board.BoardDebugProperties do
  @moduledoc false

  defstruct stroke: nil,
            stroke_width: nil,
            stroke_dash_array: nil,
            fill: nil

  def to_svg_attributes(%__MODULE__{} = properties) do
    [
      stroke: properties.stroke,
      fill: properties.fill,
      "stroke-width": properties.stroke_width,
      "stroke-dasharray": properties.stroke_dash_array
    ]
  end
end
