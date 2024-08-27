defmodule Quartz.Scale do
  @moduledoc """
  Scales for axes.
  """

  require Dantzig.Polynomial, as: Polynomial
  alias Quartz.AxisData
  alias Quartz.Sketch

  @type scale() :: {module(), atom(), Keyword.t()}

  @doc """
  Linear scale.
  """
  @spec linear() :: scale()
  def linear(), do: {__MODULE__, :linear_scale, []}

  @doc """
  Logarithmic scale.
  """
  @spec log() :: scale()
  def log(), do: {__MODULE__, :log_scale, []}

  @doc """
  Power scale with the given exponent.
  """
  @spec power(number()) :: scale()
  def power(exponent), do: {__MODULE__, :power_scale, [exponent]}

  @doc false
  def linear_scale(x), do: x

  @doc false
  def log_scale(x), do: :math.log(x)

  @doc false
  def power_scale(x, exponent), do: :math.pow(x, exponent)

  @doc false
  def apply_normalized_scale(_value, scaled_value_min, scaled_value_max, _scale)
      when scaled_value_min == scaled_value_max do
    0.5
  end

  @doc false
  def apply_normalized_scale(value, scaled_value_min, scaled_value_max, scale) do
    {scale_mod, scale_fun, scale_args} = scale
    scaled_value = apply(scale_mod, scale_fun, [value | scale_args])
    (scaled_value - scaled_value_min) / (scaled_value_max - scaled_value_min)
  end

  @doc false
  def scaled_min_max(values, scale) do
    {scale_mod, scale_fun, scale_args} = scale
    scaled_values = Enum.map(values, fn v -> apply(scale_mod, scale_fun, [v | scale_args]) end)
    Enum.min_max(scaled_values, fn -> {0.0, 1.0} end)
  end

  defp is_data_from_axis?(value, axis) do
    case value do
      %AxisData{plot_id: plot_id, axis_name: name}
      when name == axis.name and plot_id == axis.plot_id ->
        true

      _other ->
        false
    end
  end

  @doc false
  def get_substitutions_for_axis(lengths, axis) do
    use Dantzig.Polynomial.Operators

    axis_data_variables =
      Enum.flat_map(lengths, fn length ->
        Polynomial.get_variables_by(length, fn var ->
          is_data_from_axis?(var, axis)
        end)
      end)

    {start_coord, axis_size} =
      case axis.direction do
        :left_to_right ->
          start_coord = axis.x + axis.margin_start
          {start_coord, axis.size}

        :right_to_left ->
          start_coord = axis.y + axis.size + axis.margin_start
          axis_size = -1 * axis.size
          {start_coord, axis_size}

        :top_to_bottom ->
          start_coord = axis.y + axis.margin_start
          {start_coord, axis.size}

        :bottom_to_top ->
          start_coord = axis.y + axis.size + axis.margin_end
          axis_size = -1 * axis.size
          {start_coord, axis_size}
      end

    axis_scale = axis.scale

    variable_values = Enum.map(axis_data_variables, fn var -> var.value end)

    variable_values =
      if axis.min_value do
        [axis.min_value | variable_values]
      else
        variable_values
      end

    variable_values =
      if axis.max_value do
        [axis.max_value | variable_values]
      else
        variable_values
      end

    {scaled_value_min, scaled_value_max} = scaled_min_max(variable_values, axis.scale)

    substitutions =
      for variable <- axis_data_variables, into: %{} do
        scaled_value =
          apply_normalized_scale(
            variable.value,
            scaled_value_min,
            scaled_value_max,
            axis_scale
          )

        position = Polynomial.algebra(start_coord + axis_size * scaled_value)

        {variable, position}
      end

    substitutions
  end

  @doc false
  def get_substitutions_for_axes(lengths, axes) do
    subtitution_maps = Enum.map(axes, fn axis -> get_substitutions_for_axis(lengths, axis) end)

    Enum.reduce(subtitution_maps, %{}, fn subst, acc ->
      Map.merge(acc, subst)
    end)
  end

  @doc false
  def apply_scales_to_sketches_and_constraints(sketches, constraints, lengths, axes) do
    substitutions = get_substitutions_for_axes(lengths, axes)

    sketches = apply_scales_to_sketches(sketches, substitutions)
    constraints = apply_scales_to_constraints(constraints, substitutions)

    {sketches, constraints, substitutions}
  end

  @doc false
  def apply_scales_to_sketches(sketches, substitutions) do
    for {sketch_id, sketch} <- sketches, into: %{} do
      transformed_sketch =
        Sketch.transform_lengths(sketch, fn length ->
          Polynomial.substitute(length, substitutions)
        end)

      {sketch_id, transformed_sketch}
    end
  end

  @doc false
  def apply_scales_to_constraints(constraints, substitutions) do
    for {constraint_id, constraint} <- constraints, into: %{} do
      new_lhs =
        if is_number(constraint.left_hand_side) do
          constraint.left_hand_side
        else
          Polynomial.substitute(constraint.left_hand_side, substitutions)
        end

      # TODO: make sure this is needed.
      # probably not because I think constraints normalize themselves
      # so that the right hand side is a number
      new_rhs =
        if is_number(constraint.right_hand_side) do
          constraint.right_hand_side
        else
          Polynomial.substitute(constraint.right_hand_side, substitutions)
        end

      transformed_constraint = %{
        constraint
        | left_hand_side: new_lhs,
          right_hand_side: new_rhs
      }

      {constraint_id, transformed_constraint}
    end
  end
end
