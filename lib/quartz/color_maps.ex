defmodule Quartz.ColorMap.ColorMapBuilder do
  alias Quartz.Color.RGB

  def parse_color(<<r::binary-size(2), g::binary-size(2), b::binary-size(2)>>) do
    {red, ""} = Integer.parse(r, 16)
    {green, ""} = Integer.parse(g, 16)
    {blue, ""} = Integer.parse(b, 16)

    %RGB{red: red, green: green, blue: blue}
  end

  def parse_colors(colors_binary) do
    colors_binary
    |> String.codepoints
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
      Return a color for the given integer using the `#{unquote(function_name)}`.

      See `#{unquote(function_name)}/0`.

      ## Colors

      #{unquote(color_palette(colors))}
      """
      def unquote(function_name)(i) do
        color_map = apply(__MODULE__, unquote(function_name), [])
        Quartz.ColorMap.get_color(color_map, i)
      end
    end
  end
end

defmodule Quartz.ColorMap do
  require Quartz.ColorMap.ColorMapBuilder, as: ColorMapBuilder

  @derive {Inspect, only: [:name, :type]}

  defstruct name: nil,
            type: nil,
            function: nil

  def get_color(color_map, value) do
    case color_map.function do
      {m, f, opts} ->
        apply(m, f, [value, opts])

      fun when is_function(fun, 1) ->
        fun.(value)
    end
  end

  ColorMapBuilder.build_stepwise_color_map(
    "tab10",
    "schemeTableau10",
    "1f77b4ff7f0e2ca02cd627289467bd8c564be377c27f7f7fbcbd2217becf"
  )

  ColorMapBuilder.build_stepwise_color_map(
    "set1",
    "schemeSet1",
    "e41a1c377eb84daf4a984ea3ff7f00ffff33a65628f781bf999999"
  )

  ColorMapBuilder.build_stepwise_color_map(
    "set2",
    "schemeSet2",
    "66c2a5fc8d628da0cbe78ac3a6d854ffd92fe5c494b3b3b3"
  )

  ColorMapBuilder.build_stepwise_color_map(
    "set3",
    "schemeSet3",
    "8dd3c7ffffb3bebadafb807280b1d3fdb462b3de69fccde5d9d9d9bc80bdccebc5ffed6f"
  )

  ColorMapBuilder.build_stepwise_color_map(
    "pastel23",
    "schemePastel3",
    "b3e2cdfdcdaccbd5e8f4cae4e6f5c9fff2aef1e2cccccccc"
  )
end
