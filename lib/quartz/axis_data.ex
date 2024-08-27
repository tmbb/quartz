defmodule Quartz.AxisData do
  alias Quartz.Figure

  @type t() :: %__MODULE__{}

  defstruct value: nil,
            plot_id: nil,
            axis_name: nil

  def new(value, plot_id, axis_name) do
    %__MODULE__{value: value, plot_id: plot_id, axis_name: axis_name}
  end

  def new_variable(value, plot_id, axis_name) do
    Figure.variable(new(value, plot_id, axis_name))
  end

  defimpl String.Chars do
    def to_string(axis_data) do
      "data(#{axis_data.value}, #{axis_data.plot_id}.#{axis_data.axis_name})"
    end
  end
end
