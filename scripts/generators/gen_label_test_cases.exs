defmodule Quartz.Scripts.Generators.GenLabelTestCases do
  require EEx

  def run() do
    content =
      EEx.eval_file(
        "scripts/generators/templates/label_test_cases.exs",
        assigns: [
          locations: [
            %{atom: :top_left, human: "top left"},
            %{atom: :top, human: "top"},
            %{atom: :top_right, human: "top right"},
            %{atom: :right, human: "right"},
            %{atom: :bottom_right, human: "bottom right"},
            %{atom: :bottom, human: "bottom"},
            %{atom: :bottom_left, human: "bottom left"},
            %{atom: :left, human: "left"},
          ],
          fig_width_in_cm: 6,
          fig_height_in_cm: 5
        ]
      )

    File.write!("test/quartz/plot_2d/legend_test.exs", content)
  end
end

Quartz.Scripts.Generators.GenLabelTestCases.run()
