defmodule Quartz.Statistics.KDE do
  require Explorer.DataFrame, as: DataFrame
  alias Explorer.Series
  alias Quartz.Statistics.KDE.DensityEstimator1D


  # A constant used by the gaussian distribution
  @inv_sqrt_2pi 1 / :math.sqrt(2 * :math.pi())

  @doc false
  def gaussian_kernel_bandwidth_selector(series) do
    n = Series.size(series)
    sigma_hat = Series.standard_deviation(series)
    q1 = Series.quantile(series, 0.25)
    q3 = Series.quantile(series, 0.75)
    iqr = q3 - q1

    0.9 * min(sigma_hat, iqr / 1.34) * n ** (-1 / 5)
  end

  @doc false
  def gaussian_kernel(series) do
    Series.multiply(
      @inv_sqrt_2pi,
      Series.exp(
        Series.multiply(
          -0.5,
          Series.pow(
            series,
            2
          )
        )
      )
    )
  end

  @doc """
  A gaussian estimator for 1D probability distributions.
  """
  def gaussian_kernel_estimator() do
    %DensityEstimator1D{
      name: "Gaussian estimator",
      kernel: {__MODULE__, :gaussian_kernel, []},
      bandwidth_selector: {__MODULE__, :gaussian_kernel_bandwidth_selector, []}
    }
  end

  defp series_from_range(range) do
    range
    |> Enum.into([])
    |> Series.from_list()
  end

  defp apply_kernel_to_cols(estimator, bandwidth, x_col, obs_col) do
    DensityEstimator1D.apply_kernel(
      estimator,
      Series.divide(
        Series.subtract(
          x_col,
          obs_col
        ),
        bandwidth
      )
    )
  end

  defp aggregate_deltas(delta_col, n, bandwidth) do
    Series.multiply(1/(n * bandwidth), Series.sum(delta_col))
  end

  def kde(observations, nr_of_points, opts \\ []) do
    estimator =
      Keyword.get(
        opts,
        :estimator,
        gaussian_kernel_estimator()
      )

    bandwidth =
      Keyword.get(
        opts,
        :bandwidth,
        DensityEstimator1D.select_bandwidth(estimator, observations)
      )

    n_observations = Series.size(observations)
    min = Series.min(observations)
    max = Series.max(observations)

    # Estimate the bandwidth

    # Use some Explorar-based programming to keep the number-crunching
    # out of the BEAM and offload the hard calculations to Rust.

    x_df =
      DataFrame.new(
        id: series_from_range(1..nr_of_points),
        x: linear_space(min, max, nr_of_points)
      )
      |> DataFrame.lazy()

    obs_df =
      DataFrame.new(
        id: series_from_range(1..n_observations),
        obs: observations
      )
      |> DataFrame.lazy()

    # The expression that will compute the kernel function at each point.
    # These values will be later aggregated by x-value and summed together

    delta_fun = fn df ->
      apply_kernel_to_cols(estimator, bandwidth, df[:x], df[:obs])
    end

    aggregate_deltas_fun = fn df ->
      aggregate_deltas(df[:delta], nr_of_points, bandwidth)
    end

    DataFrame.join(x_df, obs_df, how: :cross, on: :id)
    |> DataFrame.mutate_with(fn df -> [delta: delta_fun.(df)] end)
    |> DataFrame.group_by(:x)
    |> DataFrame.summarise_with(fn df -> [y: aggregate_deltas_fun.(df)] end)
    |> DataFrame.collect()
  end

  # Evenly split an interval of real numbers into n parts

  defp linear_space_list(a, b, n) do
    step = (b - a) / n
    [a | Enum.reverse(Enum.map(0..(n - 2), fn i -> b - i * step end))]
  end

  defp linear_space(a, b, n) do
    Series.from_list(linear_space_list(a, b, n))
  end
end
