defmodule Quartz.LegendSymbolBuilder do
  @moduledoc """
  TODO
  """

  import Quartz.Operators, only: [algebra: 1]

  require Quartz.Figure, as: Figure
  require Quartz.KeywordSpec, as: KeywordSpec

  alias Quartz.Line
  alias Quartz.Circle
  alias Quartz.Rectangle
  alias Quartz.Length
  alias Quartz.Text
  alias Quartz.Sketch
  alias Quartz.Config

  @derive {Inspect, only: [:name]}

  @doc """
  A symbol builder.
  """
  defstruct name: nil,
            opts: [],
            builder: nil

  @doc """
  Creates a rectangle symbol builder for a legend.
  """
  def rectangle(opts) do
    %__MODULE__{
      name: "rectangle",
      opts: opts,
      builder: fn label, opts, _builder_opts ->
        KeywordSpec.validate!(opts, [
          !fill,
          opacity: 1
        ])

        width = get_label_height(label)
        height = algebra(0.6 * width)

        rectangle =
          Rectangle.new(
            fill: fill,
            opacity: opacity
          )

        Figure.assert(rectangle.width == width)
        Figure.assert(rectangle.height == height)

        rectangle
      end
    }
  end

  @doc """
  Creates a circle symbol builder for a legend.
  """
  def circle(opts) do
    %__MODULE__{
      name: "circle",
      opts: opts,
      builder: fn label, opts, _builder_opts ->
        KeywordSpec.validate!(opts, [
          !fill,
          opacity: 1
        ])

        radius = algebra(0.3 * get_label_height(label))

        Circle.new(
          radius: radius,
          fill: fill,
          opacity: opacity
        )
      end
    }
  end

  @doc """
  Creates a line symbol builder for a legend.
  """
  def line(opts) do
    %__MODULE__{
      name: "line",
      opts: opts,
      builder: fn label, opts, _builder_opts ->
        KeywordSpec.validate!(opts, [
          !stroke_paint,
          stroke_thickness: 1,
          opacity: 1
        ])

        size = get_label_height(label)

        line =
          Line.draw_new(
            stroke_paint: stroke_paint,
            stroke_thickness: stroke_thickness,
            opacity: opacity
          )

        Figure.assert(line.x2 == line.x1 + size)
        Figure.assert(line.y2 == line.y1)

        line
      end
    }
  end

  @doc """
  Builds a symbol from a symbol builder and a concrete legend.
  """
  def build(symbol, label, builder_opts) do
    symbol.builder.(label, symbol.opts, builder_opts)
  end

  @doc """
  Get the height of a label to draw a symbol marker.
  """
  def get_label_height(label) do
    case label do
      %Text{} ->
        Length.pt(label.size)

      bin when is_binary(bin) ->
        attrs = Config.get_legend_text_attributes()
        Keyword.fetch!(attrs, :size)

      _other ->
        Sketch.bbox_height(label)
    end
  end
end
