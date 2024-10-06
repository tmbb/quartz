defmodule Quartz.Color.ColorMapBuilder do
  @moduledoc false

  alias Quartz.Color.RGB

  def parse_color(<<r::binary-size(2), g::binary-size(2), b::binary-size(2)>>) do
    {red, ""} = Integer.parse(r, 16)
    {green, ""} = Integer.parse(g, 16)
    {blue, ""} = Integer.parse(b, 16)

    %RGB{red: red, green: green, blue: blue}
  end

  def parse_colors(colors_binary) do
    colors_binary
    |> String.codepoints()
    |> Enum.chunk_every(6)
    |> Enum.map(&Enum.join/1)
    |> Enum.map(&parse_color/1)
  end

  defp color_rectangle(color) do
    r = color.red
    g = color.green
    b = color.blue
    ~s[<div style="height:16px;width:48px;background:rgba(#{r},#{g},#{b},1)"></div>]
  end

  def color_palette(colors) do
    for color <- colors do
      color_rectangle(color) <> "\n"
    end
  end

  defmacro build_stepwise_color_map(name, link, color_binary) do
    colors = parse_colors(color_binary)

    function_name = String.to_atom(name)
    full_function_name = :"get_color_#{function_name}"

    function_clauses =
      for {color, i} <- Enum.with_index(colors, 0) do
        quote do
          def unquote(full_function_name)(unquote(i), _opts) do
            unquote(Macro.escape(color))
          end
        end
      end

    last_clause =
      quote do
        def unquote(full_function_name)(other, _opts) do
          apply(
            __MODULE__,
            unquote(full_function_name),
            rem(other, unquote(length(colors)))
          )
        end
      end

    all_function_clauses = function_clauses ++ [last_clause]

    quote do
      @doc """
      Cyclic colormap with #{unquote(length(colors))} colors.

      From the [D3.js project](https://d3js.org/d3-scale-chromatic/categorical##{unquote(link)})

      ## Colors

      #{unquote(color_palette(colors))}
      """
      def unquote(function_name)() do
        %Quartz.ColorMap{
          name: unquote(name),
          type: "categorical",
          function: {__MODULE__, unquote(full_function_name), []}
        }
      end

      @doc false
      unquote_splicing(all_function_clauses)

      @doc """
      Return a color for the given integer using the
      `#{unquote(function_name)}` colormap.

      See `#{unquote(function_name)}/0`.
      """
      def unquote(function_name)(i) do
        color_map = apply(__MODULE__, unquote(function_name), [])
        Quartz.ColorMap.get_color(color_map, i)
      end
    end
  end
end
