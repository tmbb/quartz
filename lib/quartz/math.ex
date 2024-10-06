defmodule Quartz.Math do
  @moduledoc """
  Math characters for typesetting math formulas.

  The full list of supported mathematical characters
  together with the functions that return them can be
  seen in this chart:

  ![Supported characters chart](assets/math_characters_chart/example.png)
  """

  # Pretty much everythin in this module is generated at compile-time
  # by macros and functions in the `Quartz.MathHelpers` module.
  require Quartz.MathHelpers, as: MathHelpers

  MathHelpers.build_function_clauses()
end
