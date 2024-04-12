defmodule Quartz2.Vector2D do
  defstruct x: nil,
            y: nil
end

defmodule Quartz2.Sketch do
  defstruct shape: nil,
            ghost: false,
            bbox: nil
end

defmodule Quartz2.BBox do
  defstruct p1: nil,
            p2: nil
end

defmodule Quartz2.Circle do
  require Quartz.KeywordSpec, as: KeywordSpec
  alias Quartz2.Vector2D

  defstruct id: nil,
            center: nil,
            radius: nil,
            style: %{}

  def new(opts) do
    KeywordSpec.validate!(opts, [!x, !y, !radius, style: %{}])

    %__MODULE__{
      center: %Vector2D{x: x, y: y},
      radius: radius,
      style: style
    }
  end
end

defmodule Quartz2.Text do
  defstruct id: nil,
            origin: nil,
            angle: nil,
            style: %{}
end

defmodule Quartz2.Rectangle do
  require Quartz.KeywordSpec, as: KeywordSpec
  alias Quartz2.Vector2D

  defstruct id: nil,
            p1: nil,
            p2: nil,
            angle: nil,
            style: %{}

  def new(opts) do
    KeywordSpec.validate!(opts, [!x, !y, !width, !height, angle: 0, style: %{}])

    %__MODULE__{
      p1: %Vector2D{x: x, y: y},
      p2: %Vector2D{x: x + width, y: y + height},
      angle: angle,
      style: style
    }
  end
end

defmodule Quartz2.Group do
  defstruct id: nil,
            p1: nil,
            p2: nil
end

defmodule Quartz2.Path do
  defstruct id: nil,
            points: [],
            style: %{}
end
