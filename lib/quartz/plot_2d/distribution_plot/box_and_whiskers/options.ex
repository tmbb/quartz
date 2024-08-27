defmodule Quartz.Plot2D.DistributionPlots.BoxAndWhiskers.Options do
  alias Quartz.Length
  alias  Quartz.Color.RGB

  defstruct outlier_style: [],
            box_width: nil,
            whisker_tip_width: nil,

            bottom_fill: RGB.pink(),
            top_fill: RGB.pink(),

            median_stroke: RGB.black,
            median_stroke_thickness: Length.pt(1),
            median_stroke_opacity: nil,
            median_stroke_linecap: nil,
            median_stroke_dasharray: nil,
            median_stroke_linejoin: nil


  def new(opts \\ []) do
    struct(__MODULE__, opts)
  end
end
