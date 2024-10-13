defmodule Quartz.SVG.Measuring do
  @moduledoc false

  alias Quartz.SVG
  alias Quartz.Sketch
  alias Quartz.Utilities

  require Logger

  def measure([], _options), do: %{}

  def measure(sketches, options) do
    {show_loaded_fonts, options} = Keyword.pop(options, :show_loaded_fonts, false)

    if show_loaded_fonts do
      Logger.debug(fn ->
        {:ok, font_list} = Resvg.list_fonts(options)
        ["Fonts loaded by Resvg:\n", inspect(font_list, pretty: true)]
      end)
    end

    svg_elements = Enum.map(sketches, &Sketch.to_unpositioned_svg/1)
    svg = SVG.svg([width: 1, height: 1], svg_elements)
    contents = SVG.doc_to_iolist(svg)

    Utilities.with_tmp_file!("-MEASUREMENT.svg", fn tmp_path ->
      # Write the generated SVG file
      File.write!(tmp_path, contents)

      # Create a map with the sketches we want to measure
      quartz_sketches =
        for sketch <- sketches, into: %{} do
          # The keys must be strings because Resvg will convert all ids into strings
          {to_string(sketch.id), sketch}
        end

      # Ask Resvg for the dimensions of the elements.
      # This will give us a list of nodes.
      resvg_nodes = Resvg.query_all(tmp_path, options)

      measured_sketches =
        for resvg_node <- resvg_nodes, into: %{} do
          # The resvg_node.id is a string (because ids in SVG files are always strings),
          # and this is why we need to create the quartz_sketches map withn string ids.
          sketch = Map.fetch!(quartz_sketches, resvg_node.id)
          # Add height and width to the current sketch
          new_sketch = Sketch.assign_measurements_from_resvg_node(sketch, resvg_node)

          {sketch.id, new_sketch}
        end

      # Return the measured sketches
      measured_sketches
    end)
  end
end
