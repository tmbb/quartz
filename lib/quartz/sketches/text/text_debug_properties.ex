defmodule Quartz.Text.TextDebugProperties do
  @moduledoc false

  defstruct height_stroke: nil,
            height_stroke_width: nil,
            height_stroke_dash_array: nil,
            height_fill: nil,
            depth_stroke: nil,
            depth_stroke_width: nil,
            depth_stroke_dash_array: nil,
            depth_fill: nil,
            baseline_stroke: nil,
            baseline_stroke_width: nil,
            baseline_stroke_dash_array: nil

  def to_baseline_svg_attributes(%__MODULE__{} = properties) do
    [
      stroke: properties.baseline_stroke,
      "stroke-width": properties.baseline_stroke_width,
      "stroke-dasharray": properties.baseline_stroke_dash_array
    ]
  end

  def to_height_svg_attributes(%__MODULE__{} = properties) do
    [
      stroke: properties.height_stroke,
      fill: properties.height_fill,
      "stroke-width": properties.height_stroke_width,
      "stroke-dasharray": properties.height_stroke_dash_array
    ]
  end

  def to_depth_svg_attributes(%__MODULE__{} = properties) do
    [
      stroke: properties.depth_stroke,
      fill: properties.depth_fill,
      "stroke-width": properties.depth_stroke_width,
      "stroke-dasharray": properties.depth_stroke_dash_array
    ]
  end
end
