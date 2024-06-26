defmodule Quartz.Figure do
  alias Dantzig.Problem
  alias Dantzig.Constraint
  alias Dantzig.Polynomial

  alias Quartz.Sketch
  alias Quartz.Scale
  alias Quartz.Point2D
  alias Quartz.Config
  alias Quartz.Canvas
  alias Quartz.AxisData
  alias Quartz.Axis2D
  alias Quartz.Plot2D
  alias Quartz.Length

  alias Quartz.SVG
  alias Quartz.SVG.Measuring

  @derive {Inspect, only: [:width, :height, :debug, :finalized]}

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

  def new(args, fun) do
    width = Keyword.get(args, :width, 300)
    height = Keyword.get(args, :height, 200)
    config = Keyword.get(args, :config, Config.new())
    debug = Keyword.get(args, :debug, false)

    default_font_dir = Path.join(
      to_string(:code.priv_dir(:quartz)),
      "fonts"
    )

    resvg_options = [
      resources_dir: Keyword.get(args, :resources_dir, "."),
      skip_system_fonts: Keyword.get(args, :skip_system_fonts, true),
      font_dirs: Keyword.get(args, :font_dirs, [default_font_dir]),
      dpi: Keyword.get(args, :dpi, 300)
    ]

    try do
      figure = %__MODULE__{
        width: width,
        height: height,
        debug: debug,
        config: config,
        resvg_options: resvg_options,
        store: %{}
      }

      Process.put(:"$quartz_figure", figure)

      cond do
        is_function(fun, 0) ->
          fun.()

        is_function(fun, 1) ->
          fun.(figure)

        is_function(fun, 2) ->
          fun.(width, height)

        true ->
          raise "Function must be of arity 0, 1 or 2"
      end

      # Get the figure that might have been modified by the code above
      figure = get_current_figure()

      figure
      |> get_measurements()
      |> finish_axes()
      |> apply_scales_to_data()
      |> align_decorations_areas()
      |> draw_plots()
      |> solve_problem()
      |> solve_sketches()
      |> finalize()
    after
      Process.delete(:"$quartz_figure")
    end
  end

  def bounds_for_plots_in_grid(opts \\ []) do
    nr_of_rows = Keyword.fetch!(opts, :nr_of_rows)
    nr_of_columns = Keyword.fetch!(opts, :nr_of_columns)

    padding = Keyword.get(opts, :padding, Length.pt(8))
    horizontal_padding = Keyword.get(opts, :horizontal_padding, padding)
    vertical_padding = Keyword.get(opts, :vertical_padding, padding)

    half_horizontal_padding = horizontal_padding / 2
    half_vertical_padding = vertical_padding / 2

    x = Keyword.get(opts, :x, 0.0)
    y = Keyword.get(opts, :y, 0.0)
    total_width = Keyword.get(opts, :total_width, current_figure_width())
    total_height = Keyword.get(opts, :total_height, current_figure_height())

    left_bounds =
      for i <- 0..Kernel.-(nr_of_columns, 1) do
        if i == 0 do
          x
        else
          x + total_width * (i / nr_of_columns) + half_horizontal_padding
        end
      end

    right_bounds =
      for i <- 0..Kernel.-(nr_of_columns, 1) do
        if i == Kernel.-(nr_of_columns, 1) do
          x + total_width
        else
          x + total_width * (Kernel.+(i, 1) / nr_of_columns) - half_horizontal_padding
        end
      end

    top_bounds =
      for i <- 0..Kernel.-(nr_of_rows, 1) do
        if i == 0 do
          y
        else
          y + total_height * (i / nr_of_rows) + half_vertical_padding
        end
      end

    bottom_bounds =
      for i <- 0..Kernel.-(nr_of_rows, 1) do
        if i == Kernel.-(nr_of_rows, 1) do
          y + total_height
        else
          y + total_height * (Kernel.+(i, 1) / nr_of_rows) - half_vertical_padding
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

  def debug?() do
    get_current_figure().debug
  end

  def render_to_svg_file!(figure, path) do
    svg_contents = to_svg_iodata(figure)
    File.write!(path, svg_contents)
  end

  def render_to_png_file!(figure, path) do
    svg_contents = to_svg_iodata(figure)
    svg_binary = IO.iodata_to_binary(svg_contents)
    Resvg.svg_string_to_png(svg_binary, path, figure.resvg_options)
  end

  def position_with_location_and_alignment(sketch, container, opts \\ []) do
    x_location = Keyword.get(opts, :x_location, :center)
    y_location = Keyword.get(opts, :y_location, :horizon)

    x_alignment = Keyword.get(opts, :x_alignment, x_location)
    y_alignment = Keyword.get(opts, :y_alignment, y_location)

    x_offset = Keyword.get(opts, :x_offset, 0)
    y_offset = Keyword.get(opts, :y_offset, 0)

    contains_vertically? = Keyword.get(opts, :contains_vertically?, false)
    contains_horizontally? = Keyword.get(opts, :contains_horizontally?, false)

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

    assert(x_left_hand_side, :==, Polynomial.add(x_right_hand_side, x_offset))
    assert(y_left_hand_side, :==, Polynomial.add(y_right_hand_side, y_offset))

    if contains_vertically? do
      assert_contains_vertically(container, sketch)
    end

    if contains_horizontally? do
      assert_contains_horizontally(container, sketch)
    end
  end

  def add_unmeasured_item(object) do
    figure = get_current_figure()
    updated_figure = %{figure | unmeasured: [object | figure.unmeasured]}
    put_current_figure(updated_figure)
  end

  defp get_measurements(figure) do
    measured = Measuring.measure(figure.unmeasured, figure.resvg_options)

    for {element_id, measured_element} <- measured do
      # Map.put(figure.sketch, element_id, measured_element)
      unmeasured_element = figure.sketches[element_id]
      # Add the new measurements to the constraints
      assert(unmeasured_element.width, :==, measured_element.width)
      assert(unmeasured_element.height, :==, measured_element.height)
    end

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

  def sort_while_keeping_canvases_behind(sketches) do
    Enum.sort_by(sketches, fn {id, sketch} ->
      case sketch do
        %Canvas{} ->
          {0, id, sketch}

        other ->
          {1, id, other}
      end
    end)
  end

  def to_svg_iodata(figure) do
    sorted_sketches = sort_while_keeping_canvases_behind(figure.sketches)
    svg_elements =
      for {_id, sketch} <- sorted_sketches do
        Sketch.to_svg(sketch)
      end

    view_box = "0 0 #{figure.width} #{figure.height}"

    svg = SVG.svg([width: figure.width, height: figure.height, viewBox: view_box], svg_elements)

    SVG.to_iodata(svg)
  end

  defp finalize(figure) do
    %{figure | finalized: true}
  end

  @doc false
  def apply_scales_to_data(figure) do
    sketches = figure.sketches
    lengths = get_all_lengths(figure)
    axes = get_all_axes(figure)

    new_sketches = Scale.apply_scales_to_sketches(sketches, lengths, axes)
    new_figure = %{figure | sketches: new_sketches}
    put_current_figure(new_figure)
    new_figure
  end

  @doc false
  def get_all_lengths(figure) do
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
    solution = Dantzig.solve(figure.problem)
    %{figure | solution: solution}
  end

  def solve(expression) do
    figure = get_current_figure()
    Polynomial.evaluate(figure.solution, expression)
  end

  def substitute(expression, substitutions) do
    Polynomial.substitute(expression, substitutions)
  end

  def solve!(expression) do
    figure = get_current_figure()
    result = Dantzig.Solution.evaluate(figure.solution, expression)
    true = is_number(result)
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

  defp update_current_figure_problem(fun) do
    figure = get_current_figure()
    problem = figure.problem
    {updated_problem, result} = fun.(problem)
    put_current_figure(%{figure | problem: updated_problem})
    result
  end

  def assert(%Point2D{} = left, :==, %Point2D{} = right) do
    update_current_figure_problem(fn problem ->
      constraint_x = Constraint.new(left.x, :==, right.x)
      constraint_y = Constraint.new(left.y, :==, right.y)

      updated_problem =
        problem
        |> Problem.add_constraint(constraint_x)
        |> Problem.add_constraint(constraint_y)

      {updated_problem, :ok}
    end)
  end

  def assert(left, operator, right) do
    update_current_figure_problem(fn problem ->
      constraint = Constraint.new(left, operator, right)
      updated_problem = Problem.add_constraint(problem, constraint)
      {updated_problem, :ok}
    end)
  end

  defmacro assert(comparison) do
    {left, operator, right} = Constraint.arguments_from_comparison!(comparison)

    quote do
      unquote(__MODULE__).assert(unquote(left), unquote(operator), unquote(right))
    end
  end

  def maximize(expression) do
    update_current_figure_problem(fn problem ->
      updated_problem = Problem.increment_objective(problem, expression)
      {updated_problem, :ok}
    end)
  end

  def minimize(expression) do
    update_current_figure_problem(fn problem ->
      updated_problem = Problem.decrement_objective(problem, expression)
      {updated_problem, :ok}
    end)
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

  @doc false
  def finish_axes(figure) do
    lengths = get_all_lengths(figure)

    data_lengths_by_axes =
      Enum.group_by(
        lengths,
        &min_max_for_axis_group_fun/1,
        &min_max_for_axis_value_fun/1
      )

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

      _other ->
        nil
    end
  end

  defp min_max_for_axis_value_fun(length) do
    case length do
      %AxisData{value: value} ->
        value

      other ->
        other
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

    assert(Sketch.bbox_left(left_object), :==, Sketch.bbox_left(container))
    assert(Sketch.bbox_right(right_object), :==, Sketch.bbox_right(container))

    :ok
  end

  def assert_contains(container, item) do
    assert_contains_vertically(container, item)
    assert_contains_horizontally(container, item)

    :ok
  end

  def assert_contains_vertically(container, item) do
    assert(Sketch.bbox_top(item), :>=, Sketch.bbox_top(container))
    assert(Sketch.bbox_bottom(item), :<=, Sketch.bbox_bottom(container))

    :ok
  end

  def assert_contains_horizontally(container, item) do
    assert(Sketch.bbox_right(item), :<=, Sketch.bbox_right(container))
    assert(Sketch.bbox_left(item), :>=, Sketch.bbox_left(container))

    :ok
  end

  def assert_vertically_contained_in(item, container) do
    assert(Sketch.bbox_top(item), :>=, Sketch.bbox_top(container))
    assert(Sketch.bbox_bottom(item), :<=, Sketch.bbox_bottom(container))

    :ok
  end

  def assert_horizontally_contained_in(item, container) do
    assert(Sketch.bbox_right(item), :<=, Sketch.bbox_right(container))
    assert(Sketch.bbox_left(item), :>=, Sketch.bbox_left(container))

    :ok
  end
end
