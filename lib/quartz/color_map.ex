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
