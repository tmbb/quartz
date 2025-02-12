defmodule Quartz.Plot2D.Text.MathCharactersChartsTest do
  use ExUnit.Case, async: true
  import Approval

  require Quartz.Figure, as: Figure
  alias Quartz.Length
  alias Quartz.Demo.Text.MathCharactersChart

  @output_dir "test/quartz/text/outputs/math_charts"

  @tag timeout: 300_000
  test "regression testing for the symbol charts in the demo" do
    # Lazy loading of categories because they must be inside a figure context
    categories = [
      {:mathematical_italic_sketches, 4, true},
      {:mathematical_symbol_sketches, 2, true},
      {:mathematical_double_struck_sketches, 6, true},
      {:mathematical_fraktur_sketches, 5, true},
      {:mathematical_script_sketches, 5, true},
      {:mathematical_bold_sketches, 4, true},
      {:mathematical_bold_italic_sketches, 3, true},
      {:mathematical_bold_script_sketches, 3, true},
      {:mathematical_monospace_sketches, 5, true},
      {:mathematical_sans_serif_bold_italic_sketches, 3, true},
      {:mathematical_sans_serif_bold_sketches, 4, true},
      {:mathematical_sans_serif_italic_sketches, 4, true},
      {:mathematical_sans_serif_sketches, 5, true}
    ]

    for {func, nr_of_columns, reviewed?} <- categories do
      snapshot_path = Path.join(@output_dir, "#{func}_snapshot.png")
      reference_path = Path.join(@output_dir, "#{func}_reference.png")

      figure =
        Figure.new([height: Length.cm(0), width: Length.cm(0)], fn fig ->
          {category, sketches} = apply(Quartz.Math, func, [[size: 14]])

          final_y =
            MathCharactersChart.character_table_with_title(
              fig,
              _y = Length.pt(4),
              category,
              sketches,
              nr_of_columns
            )

          Figure.assert(fig.height >= final_y)
        end)

      Figure.render_to_png_file!(figure, snapshot_path)

      approve snapshot: File.read!(snapshot_path),
              reference: File.read!(reference_path),
              reviewed: reviewed?
    end
  end
end
