defmodule Quartz.AxisReference do
  @doc false
  defstruct name: nil

  def new(name) do
    %__MODULE__{name: name}
  end

  defimpl Quartz.Plot2DElement do
    alias Quartz.Plot2D
    alias Quartz.Axis2D
    alias Quartz.AxisReference

    def draw(%AxisReference{} = axis_reference, %Plot2D{} = plot, x, y) do
      axis = Plot2D.fetch_axis!(plot, axis_reference.name)
      Axis2D.draw(plot, x, y, axis)
    end
  end
end
