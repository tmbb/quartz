defmodule Quartz.Figure do
  @moduledoc """
  Figure

  The figure is the highest level entity that Quartz deals with.
  Every drawing is a figure, and objects in a figure can interact
  in stateful ways that break referential transparency.
  However, figures can't interact with each other.
  """

  alias Dantzig.Problem
  alias Dantzig.Constraint
  alias Dantzig.ConstraintMetadata
  alias Dantzig.Solution

  alias Quartz.Sketch
  alias Quartz.Scale
  alias Quartz.Point2D
  alias Quartz.Config
  alias Quartz.AxisData
  alias Quartz.Axis2D
  alias Quartz.Plot2D
  alias Quartz.Length

  alias Quartz.SVG
  alias Quartz.SVG.Measuring

  require Quartz.KeywordSpec, as: KeywordSpec
  require Dantzig.Polynomial, as: Polynomial

  @default_min_max_level 10

  @derive {Inspect, only: [:width, :height, :debug, :finalized]}

  @type t() :: %__MODULE__{}

  defstruct width: nil,
            height: nil,
            problem: %Problem{direction: :maximize},
            debug: false,
            solution: nil,
            unmeasured: [],
            counter: 0,
            plots: %{},
            shared_axes: [],
            sketches: %{},
            config: nil,
            finalized: false,
            resvg_options: [],
            store: %{}

  @type bounds() :: Keyword.t()

  @doc """
  Get bounds for plots in a grid.
  Currently only regular grids are supported.

  Supports the following options:

    - `:nr_of_rows` - *required* (integer)
    - `:nr_of_columns` - *required* (integer)
    - `:padding` - *optional* (default: `Length.pt(8)`): the padding between plots
    - `:horizontal_padding` - *optional* (default: the value of `:padding`):
      the horizontal padding between plots
    - `:vertical_padding` - *optional* (default: the value of `:padding`):
      the vertical padding between plots

  Returns a neste list of bounds.
  """
  @spec bounds_for_plots_in_grid(Keyword.t()) :: list(list(bounds()))
  def bounds_for_plots_in_grid(opts \\ []) do
    nr_of_rows = Keyword.fetch!(opts, :nr_of_rows)
    nr_of_columns = Keyword.fetch!(opts, :nr_of_columns)

    padding = Keyword.get(opts, :padding, Length.pt(8))
    horizontal_padding = Keyword.get(opts, :horizontal_padding, padding)
    vertical_padding = Keyword.get(opts, :vertical_padding, padding)

    half_horizontal_padding = Polynomial.algebra(horizontal_padding / 2)
    half_vertical_padding = Polynomial.algebra(vertical_padding / 2)

    x = Keyword.get(opts, :x, 0.0)
    y = Keyword.get(opts, :y, 0.0)
    total_width = Keyword.get(opts, :total_width, current_figure_width())
    total_height = Keyword.get(opts, :total_height, current_figure_height())

    left_bounds =
      for i <- 0..(nr_of_columns - 1) do
        if i == 0 do
          x
        else
          Polynomial.algebra(x + total_width * (i / nr_of_columns) + half_horizontal_padding)
        end
      end

    right_bounds =
      for i <- 0..(nr_of_columns - 1) do
        if i == nr_of_columns - 1 do
          Polynomial.algebra(x + total_width)
        else
          Polynomial.algebra(
            x + total_width * ((i + 1) / nr_of_columns) - half_horizontal_padding
          )
        end
      end

    top_bounds =
      for i <- 0..(nr_of_rows - 1) do
        if i == 0 do
          y
        else
          Polynomial.algebra(y + total_height * (i / nr_of_rows) + half_vertical_padding)
        end
      end

    bottom_bounds =
      for i <- 0..(nr_of_rows - 1) do
        if i == nr_of_rows - 1 do
          Polynomial.algebra(y + total_height)
        else
          Polynomial.algebra(y + total_height * ((i + 1) / nr_of_rows) - half_vertical_padding)
        end
      end

    for {top, bottom} <- Enum.zip(top_bounds, bottom_bounds) do
      for {left, right} <- Enum.zip(left_bounds, right_bounds) do
        [left: left, right: right, top: top, bottom: bottom]
      end
    end
  end

  defp align_decorations_areas(figure) do
    align_group_bottom(figure)
    align_group_top(figure)
    align_group_left(figure)
    align_group_right(figure)
    figure
  end

  defp align_group_bottom(figure) do
    align_group_of_plots(figure, fn p -> p.current_bottom_bound end, fn p1, p2 ->
      assert(p1.bottom_decorations_area.y, :==, p2.bottom_decorations_area.y)
      assert(p1.bottom_decorations_area.height, :==, p2.bottom_decorations_area.height)
    end)
  end

  defp align_group_top(figure) do
    align_group_of_plots(figure, fn p -> p.current_top_bound end, fn p1, p2 ->
      assert(p1.top_decorations_area.y, :==, p2.top_decorations_area.y)
      assert(p1.top_decorations_area.height, :==, p2.top_decorations_area.height)
    end)
  end

  defp align_group_left(figure) do
    align_group_of_plots(figure, fn p -> p.current_left_bound end, fn p1, p2 ->
      assert(p1.left_decorations_area.x, :==, p2.left_decorations_area.x)
      assert(p1.left_decorations_area.width, :==, p2.left_decorations_area.width)
    end)
  end

  defp align_group_right(figure) do
    align_group_of_plots(figure, fn p -> p.current_right_bound end, fn p1, p2 ->
      assert(p1.right_decorations_area.x, :==, p2.right_decorations_area.x)
      assert(p1.right_decorations_area.width, :==, p2.right_decorations_area.width)
    end)
  end

  defp align_group_of_plots(figure, plot_bound_fun, assertions_fun) do
    groups =
      Enum.group_by(
        figure.plots,
        fn {_plot_id, plot} -> plot_bound_fun.(plot) end,
        fn {plot_id, _plot} -> plot_id end
      )

    for {_, plot_ids} <- groups do
      if length(plot_ids) > 1 do
        for {p_name1, p_name2} <- pairs(plot_ids) do
          p1 = figure.plots[p_name1]
          p2 = figure.plots[p_name2]

          assertions_fun.(p1, p2)
        end
      end
    end
  end

  defp pairs(sequence) do
    Enum.zip(sequence, Enum.drop(sequence, 1))
  end

  @doc """
  Returns true if the current figure is being created with `:debug` mode active.
  """
  def debug?() do
    get_current_figure().debug
  end

  @doc """
  Renders a figure into SVG and saves it in the given path.
  """
  @spec render_to_svg_file(Figure.t(), Path.t()) :: :ok | {:error, File.posix()}
  def render_to_svg_file(figure, path) do
    svg_contents = render_to_svg_iodata(figure)
    File.write(path, svg_contents)
  end

  @doc """
  Renders a figure into SVG and saves it in the given path.
  Raises an error if it can't write to the file.
  """
  @spec render_to_svg_file!(Figure.t(), Path.t()) :: :ok
  def render_to_svg_file!(figure, path) do
    svg_contents = render_to_svg_iodata(figure)
    File.write!(path, svg_contents)
  end

  @doc """
  Renders a figure into an SVG string (not iodata).
  """
  @spec render_to_svg_binary(Figure.t()) :: String.t()
  def render_to_svg_binary(figure) do
    figure
    |> render_to_svg_iodata()
    |> IO.iodata_to_binary()
  end

  @doc """
  Renders a figure into a PNG file and saves it in the given path.
  Raises an error if it can't write to the file.
  """
  @spec render_to_png_file!(Figure.t(), Path.t()) :: :ok | {:error, binary()}
  def render_to_png_file!(figure, path) do
    :ok = render_to_png_file(figure, path)
  end

  @doc """
  Renders a figure into a PNG file and saves it in the given path.
  """
  @spec render_to_png_file(Figure.t(), Path.t()) :: :ok | {:error, binary()}
  def render_to_png_file(figure, path) do
    svg_contents = render_to_svg_iodata(figure)
    svg_binary = IO.iodata_to_binary(svg_contents)
    Resvg.svg_string_to_png(svg_binary, path, figure.resvg_options)
  end

  @doc """
  Renders a figure into a PNG binary.
  """
  @spec render_to_png_binary(Figure.t()) :: String.t()
  def render_to_png_binary(figure) do
    svg_binary =
      figure
      |> render_to_svg_iodata()
      |> IO.iodata_to_binary()

    # We'll assume this will never fail
    {:ok, png_charlist} = Resvg.svg_string_to_png_buffer(svg_binary, figure.resvg_options)

    IO.iodata_to_binary(png_charlist)
  end

  @doc """
  Renders a figure into SVG iodata (not a string).
  """
  def render_to_svg_iodata(figure) do
    sorted_sketches = sort_while_keeping_canvases_behind(figure.sketches)

    svg_elements =
      for {_id, sketch} <- sorted_sketches do
        Sketch.to_svg(sketch)
      end

    view_box =
      "0 0 #{rounded_length(figure.width)} #{rounded_length(figure.height)}"

    svg =
      SVG.svg(
        [width: figure.width, height: figure.height, viewBox: view_box],
        svg_elements
      )

    SVG.doc_to_iolist(svg)
  end

  @doc """
  Add an unmeasure item to the figure.

  Unmeasured items are items in which the item dimensions
  can't be determined without rendering them first.
  Before rendering the final output, Quartz will render
  the unmeasured items and query the renderer for their dimensions.
  """
  def add_unmeasured_item(object) do
    figure = get_current_figure()
    updated_figure = %{figure | unmeasured: [object | figure.unmeasured]}

    put_current_figure(updated_figure)
  end

  defp get_measurements(figure) do
    Measuring.measure(figure.unmeasured, figure.resvg_options)
    # Get the current figure, which already reflects the new constraints
    figure = get_current_figure()
    # Clear the measurement queue
    %{figure | unmeasured: []}
  end

  defp draw_plots(figure) do
    for {_name, plot} <- figure.plots do
      Plot2D.draw(plot)
    end

    get_current_figure()
  end

  defp sort_while_keeping_canvases_behind(sketches) do
    Enum.sort_by(sketches, fn {id, sketch} ->
      {sketch.z_index, id, sketch}
    end)
  end

  defp get_lengths_from_constraints(figure) do
    constraints = figure.problem.constraints

    nested =
      for {_constraint_id, constraint} <- constraints do
        [constraint.left_hand_side, constraint.right_hand_side]
      end

    List.flatten(nested)
  end

  defp get_all_lengths(figure) do
    lengths_from_sketches = get_lengths_from_sketches(figure)
    lengths_from_constraints = get_lengths_from_constraints(figure)

    lengths_from_sketches ++ lengths_from_constraints
  end

  @doc false
  def apply_scales_to_data(figure) do
    sketches = figure.sketches
    constraints = figure.problem.constraints

    lengths = get_all_lengths(figure)

    axes = get_all_axes(figure)

    # Apply the scales to all places where references to axes may appear.
    # This includes the constraints and not only the sketches.
    {new_sketches, new_constraints, substitutions} =
      Scale.apply_scales_to_sketches_and_constraints(
        sketches,
        constraints,
        lengths,
        axes
      )

    unsubstituted_variables = Map.drop(figure.problem.variables, Map.keys(substitutions))

    # TODO: why are theres still leftover variables that haven't been substituted?
    # Should we replace them also in the `problem.variables`?
    variables_without_axis_data =
      for {v, problem_v} <- unsubstituted_variables,
          not is_struct(v, Quartz.AxisData),
          into: %{} do
        {v, problem_v}
      end

    # Update the constraints so that they don't refer to axes anymore
    new_problem = %{
      figure.problem
      | constraints: new_constraints,
        variables: variables_without_axis_data
    }

    # Update the figure with the new problem and the new sketches
    new_figure = %{figure | problem: new_problem, sketches: new_sketches}

    new_figure
  end

  @doc false
  def get_lengths_from_sketches(figure) do
    Enum.flat_map(figure.sketches, fn {_id, sketch} ->
      Sketch.lengths(sketch)
    end)
  end

  @doc false
  def get_all_axes(figure) do
    Enum.flat_map(figure.plots, fn {_plot_id, plot} ->
      Map.values(plot.axes)
    end)
  end

  defp solve_figure_dimensions(figure) do
    put_current_figure(figure)

    solved_width = solve!(figure.width)
    solved_height = solve!(figure.height)

    new_figure = %{figure | width: solved_width, height: solved_height}

    put_current_figure(new_figure)

    new_figure
  end

  defp solve_sketches(figure) do
    put_current_figure(figure)

    solved_sketches =
      for {id, sketch} <- figure.sketches, into: %{} do
        {id, solve_sketch!(sketch)}
      end

    figure = get_current_figure()

    %{figure | sketches: solved_sketches}
  end

  defp solve_problem(figure) do
    case Dantzig.solve(figure.problem) do
      {:ok, solution} ->
        %{figure | solution: solution}

      :error ->
        raise ArgumentError, """
        The given contraints are not solvable, and as a result the figure can't be drawn.
        """
    end
  end

  @doc false
  def solve(expression) do
    figure = get_current_figure()

    figure.solution
    |> Solution.evaluate(expression)
    |> Polynomial.to_number_if_possible()
  end

  def solve!(expression) do
    figure = get_current_figure()

    result =
      figure.solution
      |> Solution.evaluate(expression)
      |> Polynomial.to_number_if_possible()

    if not is_number(result) do
      raise RuntimeError, "#{inspect(result)} is not a number"
    end

    result
  end

  def solve_sketch!(sketch) do
    Sketch.transform_lengths(sketch, &solve!/1)
  end

  def share_axes(axes) do
    update_current_figure(fn figure ->
      axes_group = for axis <- axes, do: {axis.plot_id, axis.name}
      updated_shared_axes = [axes_group | figure.shared_axes]
      new_figure = %{figure | shared_axes: updated_shared_axes}
      {new_figure, axes}
    end)
  end

  def get_id() do
    figure = get_current_figure()
    id = figure.counter
    put_current_figure(%{figure | counter: figure.counter + 1})
    id
  end

  def add_sketch(id, sketch) do
    update_current_figure(fn figure ->
      new_figure = %{figure | sketches: Map.put(figure.sketches, id, sketch)}
      {new_figure, sketch}
    end)
  end

  def get_current_figure() do
    figure = Process.get(:"$quartz_figure")

    case figure do
      nil -> raise ArgumentError, "not inside a figure context!"
      fig -> fig
    end
  end

  def current_figure_width() do
    figure = get_current_figure()
    figure.width
  end

  def current_figure_height() do
    figure = get_current_figure()
    figure.height
  end

  def put_current_figure(figure) do
    # This public function is only meant to work inside a figure context
    _old_figure = get_current_figure()
    Process.put(:"$quartz_figure", figure)
  end

  def update_current_figure(fun) do
    figure = get_current_figure()
    {new_figure, result} = fun.(figure)
    put_current_figure(new_figure)
    result
  end

  def put_plot_in_current_figure(plot) do
    update_current_figure(fn figure ->
      updated_figure = %{figure | plots: Map.put(figure.plots, plot.id, plot)}
      {updated_figure, :ok}
    end)
  end

  @doc false
  def update_current_figure_problem(fun) do
    figure = get_current_figure()
    problem = figure.problem
    {updated_problem, result} = fun.(problem)
    put_current_figure(%{figure | problem: updated_problem})
    result
  end

  def assert(left, operator, right, metadata \\ nil)

  def assert(%Point2D{} = left, :==, %Point2D{} = right, metadata) do
    full_metadata = ConstraintMetadata.update(metadata, tags: ["Point2D_equality"])

    update_current_figure_problem(fn problem ->
      constraint_x = Constraint.new(left.x, :==, right.x)
      constraint_y = Constraint.new(left.y, :==, right.y)

      updated_problem =
        problem
        |> Problem.add_constraint(constraint_x, full_metadata)
        |> Problem.add_constraint(constraint_y, full_metadata)

      {updated_problem, {:ok, [constraint_x, constraint_y]}}
    end)
  end

  def assert(contained, :in, container, metadata) do
    full_metadata = metadata && %{metadata | tags: ["in_operator" | metadata.tags]}

    update_current_figure_problem(fn problem ->
      c_left = Constraint.new(Sketch.bbox_left(contained), :>=, Sketch.bbox_left(container))
      c_top = Constraint.new(Sketch.bbox_top(contained), :>=, Sketch.bbox_top(container))
      c_right = Constraint.new(Sketch.bbox_right(contained), :<=, Sketch.bbox_right(container))
      c_bottom = Constraint.new(Sketch.bbox_bottom(contained), :<=, Sketch.bbox_bottom(container))

      constraints = [
        c_left,
        c_top,
        c_right,
        c_bottom
      ]

      updated_problem_1 = Problem.add_constraint(problem, c_left, full_metadata)
      updated_problem_2 = Problem.add_constraint(updated_problem_1, c_top, full_metadata)
      updated_problem_3 = Problem.add_constraint(updated_problem_2, c_right, full_metadata)
      updated_problem_4 = Problem.add_constraint(updated_problem_3, c_bottom, full_metadata)

      {updated_problem_4, {:ok, constraints}}
    end)
  end

  def assert(left, operator, right, metadata) do
    full_metadata = ConstraintMetadata.update(metadata, tags: ["operator:#{operator}"])

    update_current_figure_problem(fn problem ->
      constraint = Constraint.new(left, operator, right)
      updated_problem = Problem.add_constraint(problem, constraint, full_metadata)
      {updated_problem, {:ok, [constraint]}}
    end)
  end

  defmacro assert({:==, _meta, [expr, {:max, _, [args]}]}) do
    expr = Polynomial.replace_operators(expr)
    args = Polynomial.replace_operators(args)

    quote do
      require Quartz.Figure
      fixed_expr = unquote(expr)
      Quartz.Figure.minimize(fixed_expr, level: 5)

      for arg <- unquote(args) do
        Quartz.Figure.assert(fixed_expr >= arg)
      end
    end
  end

  defmacro assert({:==, _meta, [expr, {:min, _, [args]}]}) do
    expr = Polynomial.replace_operators(expr)
    args = Polynomial.replace_operators(args)

    quote do
      require Quartz.Figure
      fixed_expr = unquote(expr)
      Quartz.Figure.maximize(fixed_expr, level: 15)

      for arg <- unquote(args) do
        Quartz.Figure.assert(fixed_expr <= arg)
      end
    end
  end

  defmacro assert(comparison, extra \\ []) do
    {left, operator, right} = Constraint.arguments_from_comparison!(comparison)

    # Should this be moved to the quoted experssion (i.e. at runtime?)
    metadata = ConstraintMetadata.from_env(__CALLER__, [])

    quote do
      # Needs to happen at runtime because `extra` may require runtime evaluation
      metadata =
        Dantzig.ConstraintMetadata.update(
          unquote(Macro.escape(metadata)),
          unquote(extra)
        )

      unquote(__MODULE__).assert(unquote(left), unquote(operator), unquote(right), metadata)
    end
  end

  defmacro maximize(expression, opts \\ []) do
    transformed_expression = min_max_transform_expression_with_opts(expression, opts)

    quote do
      unquote(__MODULE__).update_current_figure_problem(fn problem ->
        require Dantzig.Polynomial

        updated_problem =
          Dantzig.Problem.increment_objective(
            problem,
            unquote(transformed_expression)
          )

        {updated_problem, :ok}
      end)
    end
  end

  defmacro minimize(expression, opts \\ [])

  defmacro minimize({:abs, _meta, [expression]}, opts) do
    transformed_expression = min_max_transform_expression_with_opts(expression, opts)

    metadata = Dantzig.ConstraintMetadata.from_env(__CALLER__, [])

    quote do
      unquote(__MODULE__).update_current_figure_problem(fn problem ->
        metadata = unquote(Macro.escape(metadata))
        full_metadata = ConstraintMetadata.update(metadata, tags: ["operator:abs"])

        require Dantzig.Polynomial

        # Cache the expression because we'll be using it twice
        cached_expression = unquote(transformed_expression)

        # Create a new dummy variable
        {updated_problem, dummy_var} =
          Dantzig.Problem.new_variable(
            problem,
            "dummy_var_for_absolute_value"
          )

        # Add the two constraints that will ensure we'll be minimizing the absolute value
        c1 =
          Dantzig.Constraint.new(
            Dantzig.Polynomial.subtract(0, dummy_var),
            :<=,
            cached_expression
          )

        c2 = Dantzig.Constraint.new(dummy_var, :>=, cached_expression)

        updated_problem =
          updated_problem
          |> Dantzig.Problem.add_constraint(c1, full_metadata)
          |> Dantzig.Problem.add_constraint(c2, full_metadata)
          |> Dantzig.Problem.decrement_objective(dummy_var)

        {updated_problem, :ok}
      end)
    end
  end

  defmacro minimize(expression, opts) do
    transformed_expression = min_max_transform_expression_with_opts(expression, opts)

    quote do
      unquote(__MODULE__).update_current_figure_problem(fn problem ->
        require Dantzig.Polynomial

        updated_problem =
          Dantzig.Problem.decrement_objective(
            problem,
            unquote(transformed_expression)
          )

        {updated_problem, :ok}
      end)
    end
  end

  defp min_max_transform_expression_with_opts(expression, opts) do
    level = Keyword.get(opts, :level, @default_min_max_level)

    quote do
      Dantzig.Polynomial.algebra(unquote(level) * unquote(expression))
    end
  end

  @doc """
  Place a sketch in a canvas with the given parameters.s
  """
  def place_in_canvas(sketch, canvas, opts) do
    KeywordSpec.validate!(opts,
      x: :center,
      y: :horizon,
      horizontal_alignment: :center,
      vertical_alignment: :horizon,
      contained_horizontally_in_canvas: false,
      contained_vertically_in_canvas: false
    )

    x_location =
      case x do
        nil -> nil
        :left -> Sketch.bbox_left(canvas)
        :center -> Sketch.bbox_center(canvas)
        :right -> Sketch.bbox_right(canvas)
        other -> Polynomial.algebra(Sketch.bbox_left(canvas) + other)
      end

    y_location =
      case y do
        nil -> nil
        :top -> Sketch.bbox_top(canvas)
        :horizon -> Sketch.bbox_horizon(canvas)
        :bottom -> Sketch.bbox_bottom(canvas)
        other -> Polynomial.algebra(Sketch.bbox_top(canvas) + other)
      end

    x_handle =
      case horizontal_alignment do
        :left -> Sketch.bbox_left(sketch)
        :center -> Sketch.bbox_center(sketch)
        :right -> Sketch.bbox_right(sketch)
      end

    y_handle =
      case vertical_alignment do
        :top -> Sketch.bbox_top(sketch)
        :horizon -> Sketch.bbox_horizon(sketch)
        :baseline -> Sketch.bbox_baseline(sketch)
        :bottom -> Sketch.bbox_bottom(sketch)
      end

    if x_location, do: assert(x_handle == x_location, tags: ["placement_in_canvas"])
    if y_location, do: assert(y_handle == y_location, tags: ["placement_in_canvas"])

    if contained_vertically_in_canvas do
      assert(Sketch.bbox_top(sketch) >= Sketch.bbox_top(canvas),
        tags: ["contained_vertically_in_canvas"]
      )

      assert(Sketch.bbox_bottom(sketch) <= Sketch.bbox_bottom(canvas),
        tags: ["contained_vertically_in_canvas"]
      )
    end

    if contained_horizontally_in_canvas do
      assert(
        Sketch.bbox_left(sketch) >= Sketch.bbox_left(canvas),
        tags: ["contained_horizontally_in_canvas"]
      )

      assert(Sketch.bbox_right(sketch) <= Sketch.bbox_right(canvas),
        tags: ["contained_horizontally_in_canvas"]
      )
    end
  end

  def variable(name, opts \\ []) do
    update_current_figure_problem(fn problem ->
      {_updated_problem, _monomial} = Problem.new_variable(problem, name, opts)
    end)
  end

  def stack_vertically(objects) do
    pairs = Enum.zip(objects, Enum.drop(objects, 1))
    # Ensure everything stacks
    for {top_of_pair, bottom_of_pair} <- pairs do
      assert(
        Sketch.bbox_bottom(top_of_pair),
        :==,
        Sketch.bbox_top(bottom_of_pair)
      )
    end
  end

  def stack_vertically(objects, inside: container) do
    # Ensure everything stacks
    stack_vertically(objects)
    top_object = Enum.at(objects, 0)
    bottom_object = Enum.at(objects, -1)

    for object <- objects do
      assert_contains_vertically(container, object)
    end

    assert(Sketch.bbox_top(top_object), :==, Sketch.bbox_top(container))
    assert(Sketch.bbox_top(bottom_object), :==, Sketch.bbox_bottom(container))

    :ok
  end

  def stack_horizontally(objects) do
    pairs = Enum.zip(objects, Enum.drop(objects, 1))
    # Ensure everything stacks
    for {top_of_pair, bottom_of_pair} <- pairs do
      assert(
        Sketch.bbox_right(top_of_pair),
        :==,
        Sketch.bbox_left(bottom_of_pair)
      )
    end
  end

  defp group_by_axis(lengths) do
    data_lengths_by_axes =
      Enum.group_by(
        lengths,
        &min_max_for_axis_group_fun/1,
        &min_max_for_axis_value_fun/1
      )

    data_lengths_by_axis_flattened =
      for {axis, values} <- data_lengths_by_axes, into: %{} do
        {axis, List.flatten(values)}
      end

    data_lengths_by_axis_flattened
  end

  @doc false
  def finish_axes(figure) do
    lengths = get_all_lengths(figure)

    data_lengths_by_axes = group_by_axis(lengths)

    min_maxs =
      for {{plot_id, axis_name}, values} <- data_lengths_by_axes, into: %{} do
        min_max = Enum.min_max(values, fn -> {0.0, 1.0} end)
        {{plot_id, axis_name}, min_max}
      end

    figure =
      Enum.reduce(min_maxs, figure, fn {{plot_id, axis_name}, {min, max}}, current_figure ->
        update_plot_axis(current_figure, plot_id, axis_name, fn axis ->
          axis
          |> Axis2D.maybe_set_limits(min, max)
          |> Axis2D.fix_limits()
        end)
      end)

    figure
  end

  defp update_plot(figure, plot_id, fun) do
    new_plots = Map.update(figure.plots, plot_id, nil, fun)
    %{figure | plots: new_plots}
  end

  defp update_plot_axis(figure, plot_id, axis_name, fun) do
    update_plot(figure, plot_id, fn plot ->
      Plot2D.update_axis(plot, axis_name, fun)
    end)
  end

  defp min_max_for_axis_group_fun(length) do
    case length do
      %AxisData{} = axis_data ->
        {axis_data.plot_id, axis_data.axis_name}

      %Polynomial{} = polynomial ->
        variables =
          Polynomial.get_variables_by(polynomial, fn x ->
            is_struct(x, AxisData)
          end)

        case variables do
          [] ->
            nil

          [variable | _] ->
            {variable.plot_id, variable.axis_name}
        end

      _other ->
        nil
    end
  end

  defp min_max_for_axis_value_fun(length) do
    case length do
      %AxisData{value: value} ->
        [value]

      %Polynomial{} = polynomial ->
        variables =
          Polynomial.get_variables_by(polynomial, fn x ->
            is_struct(x, AxisData)
          end)

        case variables do
          [] ->
            nil

          other when is_list(other) ->
            for v <- other, do: v.value
        end

      _other ->
        []
    end
  end

  def center_on(object, container) do
    assert(Sketch.bbox_center(object), :==, Sketch.bbox_center(container))
  end

  def stack_horizontally(objects, inside: container) do
    # Ensure everything stacks
    stack_horizontally(objects)
    left_object = Enum.at(objects, 0)
    right_object = Enum.at(objects, -1)

    for object <- objects do
      assert_contains_horizontally(container, object)
    end

    assert(Sketch.bbox_left(left_object) == Sketch.bbox_left(container))
    assert(Sketch.bbox_right(right_object) == Sketch.bbox_right(container))

    :ok
  end

  def assert_contains(container, item) do
    assert_contains_vertically(container, item)
    assert_contains_horizontally(container, item)

    :ok
  end

  def assert_contains_vertically(container, item) do
    extra = [tags: ["horizontally_contains:#{container.id}:#{item.id}"]]

    assert(Sketch.bbox_top(item) >= Sketch.bbox_top(container), extra)
    assert(Sketch.bbox_bottom(item) <= Sketch.bbox_bottom(container), extra)

    :ok
  end

  def assert_contains_horizontally(container, item) do
    extra = [tags: ["horizontally_contains:#{container.id}:#{item.id}"]]

    assert(Sketch.bbox_right(item) <= Sketch.bbox_right(container), extra)
    assert(Sketch.bbox_left(item) >= Sketch.bbox_left(container), extra)

    :ok
  end

  def assert_vertically_contained_in(item, container) do
    assert(Sketch.bbox_top(item) >= Sketch.bbox_top(container))
    assert(Sketch.bbox_bottom(item) <= Sketch.bbox_bottom(container))

    :ok
  end

  def assert_horizontally_contained_in(item, container) do
    assert(
      Sketch.bbox_right(item) <= Sketch.bbox_right(container)
    )

    assert(
      Sketch.bbox_left(item) >= Sketch.bbox_left(container)
    )

    :ok
  end

  @doc """
  TODO: document this
  """
  def position_with_location_and_alignment(sketch, container, opts \\ []) do
    KeywordSpec.validate!(opts,
      x_location: :center,
      y_location: :horizon,
      x_alignment: x_location,
      y_alignment: y_location,
      x_offset: 0,
      y_offset: 0,
      contains_vertically?: false,
      contains_horizontally?: false
    )

    x_left_hand_side =
      case x_location do
        :left ->
          Sketch.bbox_left(sketch)

        :center ->
          Sketch.bbox_center(sketch)

        :right ->
          Sketch.bbox_right(sketch)
      end

    y_left_hand_side =
      case y_location do
        :top ->
          Sketch.bbox_top(sketch)

        :horizon ->
          Sketch.bbox_horizon(sketch)

        :bottom ->
          Sketch.bbox_bottom(sketch)
      end

    x_right_hand_side =
      case x_alignment do
        :left ->
          Sketch.bbox_left(container)

        :center ->
          Sketch.bbox_center(container)

        :right ->
          Sketch.bbox_right(container)
      end

    y_right_hand_side =
      case y_alignment do
        :top ->
          Sketch.bbox_top(container)

        :horizon ->
          Sketch.bbox_horizon(container)

        :bottom ->
          Sketch.bbox_bottom(container)
      end

    assert(x_left_hand_side == Polynomial.add(x_right_hand_side, x_offset))
    assert(y_left_hand_side == Polynomial.add(y_right_hand_side, y_offset))

    if contains_vertically? do
      assert_contains_vertically(container, sketch)
    end

    if contains_horizontally? do
      assert_contains_horizontally(container, sketch)
    end
  end

  defp finalize(figure) do
    %{figure | finalized: true}
  end

  @doc """
  Create a new figure.
  """
  def new(args, fun) do
    default_font_dir =
      Path.join(
        to_string(:code.priv_dir(:quartz)),
        "fonts"
      )

    KeywordSpec.validate!(args,
      debug: false,
      config: Config.default_config(),
      skip_system_fonts: true,
      resources_dir: ".",
      font_dirs: [default_font_dir],
      dpi: 300
    )

    min_width = Keyword.get(args, :width, Length.cm(12))
    min_height = Keyword.get(args, :height, Length.cm(8))

    resvg_options = [
      resources_dir: resources_dir,
      skip_system_fonts: skip_system_fonts,
      font_dirs: font_dirs,
      dpi: dpi
    ]

    try do
      # Figure without width or height
      figure = %__MODULE__{
        width: nil,
        height: nil,
        debug: debug,
        config: config,
        resvg_options: resvg_options,
        store: %{}
      }

      # Put the figure so that we can generate variables for the width and height
      Process.put(:"$quartz_figure", figure)

      # Add units of measurement
      :ok =
        update_current_figure_problem(fn problem ->
          # Add variables that correspond to units of measurement.
          {problem, u_cm} = Problem.new_unmangled_variable(problem, "U_cm")
          {problem, u_mm} = Problem.new_unmangled_variable(problem, "U_mm")
          {problem, u_in} = Problem.new_unmangled_variable(problem, "U_in")
          {problem, u_pt} = Problem.new_unmangled_variable(problem, "U_pt")

          # create constraints that specify the value of each unit of measurement in px
          c_cm = Constraint.new(u_cm, :==, Length.cm_to_px_conversion_factor())
          c_mm = Constraint.new(u_mm, :==, Length.mm_to_px_conversion_factor())
          c_in = Constraint.new(u_in, :==, Length.inch_to_px_conversion_factor())
          c_pt = Constraint.new(u_pt, :==, Length.pt_to_px_conversion_factor())

          metadata = ConstraintMetadata.from_env(__ENV__, tags: ["length_constant"])

          updated_problem =
            problem
            |> Problem.add_constraint(c_cm, metadata)
            |> Problem.add_constraint(c_mm, metadata)
            |> Problem.add_constraint(c_in, metadata)
            |> Problem.add_constraint(c_pt, metadata)

          {updated_problem, :ok}
        end)

      # Now that we have a figure, we can generate variables for the width and height.
      # Quartz will try to design the smallest figure that fits the elements,
      # with minimum values for width and height as given by the user.
      width = variable("figure_width")
      height = variable("figure_height")

      assert(width >= min_width)
      assert(height >= min_height)

      # Update the figure with the height and width variables
      update_current_figure(fn fig ->
        {%{fig | width: width, height: height}, :ok}
      end)

      # Get the updated figure from the current process so that it can be used below
      # as an argument to the anonymous function
      figure = get_current_figure()

      cond do
        is_function(fun, 0) ->
          fun.()

        is_function(fun, 1) ->
          fun.(figure)

        true ->
          raise "Function must be of arity 0 or 1"
      end

      # Get the figure that might have been modified by the code above
      figure = get_current_figure()

      figure
      |> finish_axes()
      |> align_decorations_areas()
      |> draw_plots()
      |> get_measurements()
      |> apply_scales_to_data()
      |> dynamically_apply_coefficients_to_figure_dimensions()
      |> solve_problem()
      |> solve_figure_dimensions()
      |> solve_sketches()
      |> finalize()
    after
      Process.delete(:"$quartz_figure")
    end
  end

  @doc false
  def dump_to_debug_file(figure) do
    # This function is meant to be used in development only.
    # TODO: find a better way to debug figures.
    File.write!("problem.lp", Dantzig.HiGHS.to_lp_iodata(figure.problem))
    figure
  end

  defp dynamically_apply_coefficients_to_figure_dimensions(figure) do
    max_coeff =
      figure.problem.objective
      |> Polynomial.coefficients()
      |> Enum.map(&abs/1)
      |> Enum.sum()

    minimization_level = 2 * max_coeff

    minimize(figure.width, level: minimization_level)
    minimize(figure.height, level: minimization_level)

    objective = figure.problem.objective

    new_objective =
      Polynomial.algebra(objective - max_coeff * figure.width - max_coeff * figure.height)

    %{figure | problem: %{figure.problem | objective: new_objective}}
  end

  def add_plot_2d(fun) do
    Plot2D.new()
    |> fun.()
    |> Plot2D.finalize()
  end

  defp rounded_length(value) when is_integer(value), do: to_string(value)

  defp rounded_length(float) when is_float(float) do
    :erlang.float_to_binary(float, decimals: 5)
  end
end
