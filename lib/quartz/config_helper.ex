defmodule Quartz.ConfigHelper do
  @moduledoc false

  defmacro def_getter_and_setter(name, text, _guards \\ nil) do
    getter_name = :"get_#{name}"
    setter_name = :"put_#{name}"

    quote do
      @doc """
      Gets the default #{unquote(text)}.

      Optional arguments:

        - `opts` (default: `[]`): a keyword list of options
          that override the default values taken from `get_config/0`

      Only works inside a figure context.
      """
      def unquote(getter_name)(opts \\ []) do
        unquote(name)(get_config(), opts)
      end

      @doc """
      Outs the the default #{unquote(text)} into the given `item`.

      Optional arguments:

        - `opts` (default: `[]`): a keyword list of options
          that override the default values taken from `get_config/0`

      Only works inside a figure context.
      """
      def unquote(setter_name)(item, opts \\ []) do
        unquote(setter_name)(item, unquote(getter_name)(opts))
      end
    end
  end
end
