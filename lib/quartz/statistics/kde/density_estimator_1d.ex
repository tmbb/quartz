defmodule Quartz.Statistics.KDE.DensityEstimator1D do
  @moduledoc false

  @derive {Inspect, only: [:name]}

  defstruct name: nil,
            kernel: nil,
            bandwidth_selector: nil

  def apply_kernel(estimator, observations) do
    {mod, fun, args} = estimator.kernel
    apply(mod, fun, [observations | args])
  end

  def select_bandwidth(estimator, observations) do
    {mod, fun, args} = estimator.bandwidth_selector
    apply(mod, fun, [observations | args])
  end
end
