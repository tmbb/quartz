defmodule Quartz.Variable do
  alias Quartz.Figure

  @moduledoc false

  def maybe_variable(struct_opts, key, variable_name, variable_opts) do
    case Keyword.fetch(struct_opts, key) do
      {:ok, variable} ->
        variable

      :error ->
        Figure.variable(variable_name, variable_opts)
    end
  end

  def maybe_with_prefix(nil, variable_name), do: variable_name
  def maybe_with_prefix(prefix, variable_name), do: "#{prefix}_#{variable_name}"
end
