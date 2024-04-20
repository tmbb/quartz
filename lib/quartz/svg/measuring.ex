defmodule Quartz.SVG.Measuring do
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
    svg = SVG.svg([x: "72pt", y: "72pt", viewBox: "0 0 72 72"], svg_elements)
    contents = SVG.to_iodata(svg)

    Utilities.with_tmp_file!("-MEASUREMENT.svg", fn tmp_path ->
      # Write the generated SVG file
      File.write!(tmp_path, contents)

      # Create a map with the sketches we want to measure
      quartz_sketches = for sketch <- sketches, into: %{} do
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
          new_sketch = %{sketch | width: resvg_node.width, height: resvg_node.height}
          {sketch.id, new_sketch}
        end

      # Return the measured sketches
      measured_sketches
    end)
  end

  def test() do
    alias Quartz.Figure
    alias Quartz.Text

    resvg_options = [
      resources_dir: ".",
      skip_system_fonts: true,
      font_dirs: ["priv/fonts"],
      dpi: 600
    ]

    Figure.new([width: 100, height: 100], fn _ ->
      elements = [
        Text.new("this is some text",
          id: 1, size: 12,
          x: 0, y: 50,
          font: "Linux Libertine"
        )
      ]

      measure(elements, resvg_options)
    end)
  end
end
