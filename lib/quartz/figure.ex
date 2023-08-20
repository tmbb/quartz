defmodule Quartz.Figure do
  alias Dantzig.Problem
  alias Dantzig.Constraint
  alias Quartz.Sketch
  alias Quartz.Point2D
  alias Quartz.Config
  alias Quartz.Canvas
  alias Quartz.Typst.Serializer
  alias Quartz.Typst.Measuring
  alias Quartz.Typst.TypstAst
  alias Dantzig.Polynomial

  @derive {Inspect, only: [:width, :height, :finalized]}

  defstruct width: nil,
            height: nil,
            problem: %Problem{direction: :maximize},
            solution: nil,
            unmeasured: [],
            counter: 0,
            plots: %{},
            shared_axes: [],
            sketches: %{},
            config: nil,
            finalized: false,
            store: %{}

  def new(args, fun) do
    width = Keyword.get(args, :width, 300)
    height = Keyword.get(args, :height, 200)
    config = Keyword.get(args, :config, Config.new())

    try do
      figure = %__MODULE__{width: width, height: height, config: config, store: %{}}

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
      |> fix_axes_limits()
      |> apply_scales_to_data()
      |> draw_plots()
      |> solve_problem()
      |> solve_sketches()
      |> finalize()
    after
      Process.delete(:"$quartz_figure")
    end
  end

  def render_to_pdf!(figure, path) do
    # Convert the figure into Typst AST (easier to manipulate than binaries)
    typst_ast = to_typst(figure)

    # Serialize the AST into a binary
    typst_binary =
      IO.iodata_to_binary([
        "#set page(width: auto, height: auto, margin: 0.5cm)\n#",
        Serializer.serialize(typst_ast)
      ])

    # Render the typst code into PDF
    pdf_binary = ExTypst.render_to_pdf!(typst_binary, [])

    # Save the PDF to a file
    File.write!(path, pdf_binary)
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
    measured = Measuring.measure(figure.unmeasured)

    for {element_id, measured_element} <- measured do
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
      Quartz.Plot2D.draw(plot)
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

  def to_typst(figure) do
    sorted_sketches = sort_while_keeping_canvases_behind(figure.sketches)

    typst_sketches =
      for {_id, sketch} <- sorted_sketches do
        Sketch.to_typst(sketch)
      end

    content = TypstAst.sequence(typst_sketches)

    box =
      TypstAst.function_call(
        TypstAst.variable("box"),
        TypstAst.named_arguments_from_proplist(
          width: TypstAst.pt(figure.width),
          height: TypstAst.pt(figure.height)
        ) ++ [content]
      )

    box
  end

  defp finalize(figure) do
    %{figure | finalized: true}
  end

  defp apply_scales_to_data(figure) do
    figure
  end

  defp fix_axes_limits(figure) do
    figure
  end

  defp solve_sketches(figure) do
    put_current_figure(figure)

    solved_sketches =
      for {id, sketch} <- figure.sketches, into: %{} do
        {id, Sketch.solve(sketch)}
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
    Dantzig.Solution.evaluate(figure.solution, expression)
  end

  def solve!(expression) do
    figure = get_current_figure()
    result = Dantzig.Solution.evaluate(figure.solution, expression)
    true = is_number(result)
    result
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
end
