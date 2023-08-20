defmodule Quartz.Color.RGB do
  defstruct red: 0,
            blue: 0,
            green: 0,
            alpha: 256

  @type t :: %__MODULE__{}

  require Quartz.Color.FunctionBuilder, as: FunctionBuilder
  FunctionBuilder.build_css_color_functions()
end
