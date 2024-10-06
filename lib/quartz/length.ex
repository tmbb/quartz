defmodule Quartz.Length do
  @moduledoc """
  Units of measurement for lengths.

  ## Implementation note

  In Quartz, all lengths are represented in points (pt)
  as floating point values. They are unitless.
  The functions in this module return unitless values
  in points by applying the proper conversion factor
  to their arguments.
  """

  alias Quartz.AxisData
  require Quartz.KeywordSpec, as: KeywordSpec
  require Dantzig.Polynomial, as: Polynomial

  @cm_factor 72 / 2.54
  @mm_factor 72 / 25.4
  @inch_factor 72

  def inch_to_pt_conversion_factor(), do: @inch_factor
  def mm_to_pt_conversion_factor(), do: @mm_factor
  def cm_to_pt_conversion_factor(), do: @cm_factor

  def inch(value) do
    Polynomial.monomial(value, "U_inch")
  end

  def pt(value) do
    Polynomial.monomial(value, "U_pt")
  end

  def mm(value) do
    Polynomial.monomial(value, "U_mm")
  end

  def cm(value) do
    Polynomial.monomial(value, "U_cm")
  end

  @doc """
  Data units.
  """
  def data(value, opts \\ []) do
    KeywordSpec.validate!(opts,
      plot_id: nil,
      axis_name: nil
    )

    axis_data = %AxisData{value: value, plot_id: plot_id, axis_name: axis_name}

    Polynomial.monomial(1, axis_data)
  end

  def axis_fraction(value, opts \\ []) do
    KeywordSpec.validate!(opts,
      axis: nil
    )

    case axis do
      nil ->
        Polynomial.monomial(value, "AXIS_SIZE")

      axis ->
        Polynomial.multiply(value, axis.size)
    end
  end
end
