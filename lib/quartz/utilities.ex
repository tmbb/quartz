defmodule Quartz.Utilities do
  @moduledoc false

  @basename_characters Enum.into(?0..?9, []) ++ Enum.into(?a..?z, [])

  @float_decimals 5

  def with_tmp_file!(suffix, fun) do
    charlist = Enum.map(1..32, fn _ -> Enum.random(@basename_characters) end)
    basename = to_string(charlist) <> suffix
    tmp_file = Path.join([System.tmp_dir!(), basename])

    try do
      fun.(tmp_file)
    after
      File.rm(tmp_file)
    end
  end

  @doc """
  A function to display rounded floats with a given number of decimals.
  The goal of defining this function here is to centralize the default number
  of decimal places for floats that are used as part of drawing dimensions.
  """
  def display_rounded_float(float, decimals \\ @float_decimals)

  def display_rounded_float(value, _decimals) when is_integer(value), do: to_string(value)

  def display_rounded_float(float, decimals) when is_float(float) do
    :erlang.float_to_binary(float, decimals: decimals)
  end
end
