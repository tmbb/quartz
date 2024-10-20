defmodule Quartz.Length do
  @moduledoc """
  Units of measurement for lengths.
  """

  alias Quartz.AxisData
  require Quartz.KeywordSpec, as: KeywordSpec
  require Dantzig.Polynomial, as: Polynomial

  @cm_factor 37.795
  @mm_factor 3.7795
  @inch_factor 96
  @pt_factor 4.0 / 3.0

  @common_doc_message """
  As a user, you probably won't have to use these conversion functions,
  but they can be useful as reference.

  > #### Note {: .info}
  >
  > *Note*: SVG pixels (px) are not real pixels on the screen.
  > The definition of an SVG pixel is much more complicated.
  """

  @doc """
  The factor that converts inches to SVG pixels (#{@inch_factor}).

  #{@common_doc_message}
  """
  @spec inch_to_px_conversion_factor() :: number()
  def inch_to_px_conversion_factor(), do: @inch_factor

  @doc """
  The factor that converts millimiters to SVG pixels (#{@mm_factor}).

  #{@common_doc_message}
  """
  @spec mm_to_px_conversion_factor() :: number()
  def mm_to_px_conversion_factor(), do: @mm_factor

  @doc """
  The factor that converts inches to SVG pixels (4/3 ≅ 1.333).

  #{@common_doc_message}
  """
  @spec cm_to_px_conversion_factor() :: number()
  def cm_to_px_conversion_factor(), do: @cm_factor

  @doc """
  The factor that converts points to SVG pixels (#{@pt_factor}).

  #{@common_doc_message}
  """
  @spec pt_to_px_conversion_factor() :: number()
  def pt_to_px_conversion_factor(), do: @pt_factor

  @doc """
  Length in inches.
  """
  @spec inch(number()) :: Polynomial.t()
  def inch(value \\ 1.0) do
    Polynomial.monomial(value, "U_inch")
  end

  @doc """
  Length in points (1 in = 96 pt).
  """
  @spec pt(number()) :: Polynomial.t()
  def pt(value \\ 1.0) do
    Polynomial.monomial(value, "U_pt")
  end

  @doc """
  Length in mm (1 in = 254 pt).
  """
  @spec mm(number()) :: Polynomial.t()
  def mm(value \\ 1.0) do
    Polynomial.monomial(value, "U_mm")
  end

  @doc """
  Length in mm (1in = 2.54cm).
  """
  def cm(value \\ 1.0) do
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

  @doc """
  A value that represents a fraction of the length of an axis (margins included).

  The value can be any real number, even though real numbers not between 0 an 1
  won't be very useful in practice.

  Takes the optional keyword argument `:axis`, which must be an axis from a plot
  (not only an axis name). If the axis is not given, some functinos that accept
  axis fractions can infer it from the context.
  """
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
