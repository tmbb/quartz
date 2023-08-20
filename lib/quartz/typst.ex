defmodule Quartz.Typst do
  alias Quartz.Typst.Text

  def text(content, opts \\ []) do
    Text.new(content, opts)
  end

  def underscore_in_keys_to_hyphen(list) when is_list(list) do
    for {key, value} <- list do
      new_key =
        key
        |> to_string()
        |> String.replace("_", "-")

      {new_key, value}
    end
  end

  def underscore_in_keys_to_hyphen(%{} = map) do
    map
    |> Enum.into([])
    |> underscore_in_keys_to_hyphen()
    |> Enum.into(%{})
  end
end
