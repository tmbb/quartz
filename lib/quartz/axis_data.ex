defmodule Quartz.AxisData do
  alias Dantzig.Polynomial

  @type t() :: %__MODULE__{}

  defstruct axis_name: nil

  def new(axis_name) do
    %__MODULE__{axis_name: axis_name}
  end

  def get_data_value(p, axis_data) do
    Polynomial.coefficient_for(p, [axis_data])
  end

  defimpl String.Chars do
    def to_string(axis_data) do
      "data@(#{axis_data.axis_name})"
    end
  end
end
