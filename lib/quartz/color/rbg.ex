defmodule Quartz.Color.RGB do
  defstruct red: 0,
            green: 0,
            blue: 0,
            alpha: 1.0

  @type t :: %__MODULE__{}

  require Quartz.Color.FunctionBuilder, as: FunctionBuilder
  FunctionBuilder.build_css_color_functions()

  def put_opacity(%__MODULE__{} = color, alpha) do
    %{color | alpha: alpha}
  end
end
