defmodule Quartz.KeywordSpec do
  @moduledoc false

  # A helper to deal with long optional arguments lists.

  @doc """
  Create variables and validate their presence from a keyword list
  and a specification.
  """
  defmacro validate!(keywords, spec) when is_list(spec) do
    dummy_var = Macro.var(:dummy_var, __MODULE__)

    dummy_assignment =
      quote do
        unquote(dummy_var) = unquote(keywords)
      end

    assignments =
      for variable <- spec do
        case variable do
          {:!, _meta1, [{var_name, _meta2, _context} = variable]} ->
            quote do
              unquote(variable) =
                Keyword.fetch!(
                  unquote(dummy_var),
                  unquote(var_name)
                )
            end

          {var_name, _meta, _context} = variable ->
            quote do
              unquote(variable) =
                Keyword.get(
                  unquote(dummy_var),
                  unquote(var_name)
                )
            end

          {var_name, expression} when is_atom(var_name) ->
            quote do
              unquote(Macro.var(var_name, nil)) =
                Keyword.get(
                  unquote(dummy_var),
                  unquote(var_name),
                  unquote(expression)
                )
            end
        end
      end

    quote do
      unquote(dummy_assignment)
      unquote_splicing(assignments)
    end
  end
end
