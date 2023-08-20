defmodule Quartz.Plot2D do
  require Quartz.Figure, as: Figure
  alias Quartz.Canvas
  alias Quartz.Axis2D
  alias Quartz.Length
  alias Quartz.Text
  alias Quartz.Sketch
  alias Quartz.Typst.TypstAst
  alias Quartz.Config
  use Dantzig.Polynomial.Operators

  defstruct id: nil,
            title: nil,
            title_alignment: :left,
            title_location: :left,
            title_inner_padding: Length.pt(5),
            padding_top: Length.pt(5),
            padding_right: Length.pt(5),
            padding_bottom: Length.pt(5),
            padding_left: Length.pt(5),
            top: nil,
            bottom: nil,
            left: nil,
            right: nil,
            top_content: [],
            right_content: [],
            bottom_content: [],
            left_content: [],
            data: [],
            axes: %{},
            plot_area: nil,
            title_area: nil,
            data_area: nil,
            top_decorations_area: nil,
            top_right_decorations_area: nil,
            right_decorations_area: nil,
            bottom_right_decorations_area: nil,
            bottom_decorations_area: nil,
            bottom_left_decorations_area: nil,
            left_decorations_area: nil,
            top_left_decorations_area: nil

  def add_bottom_axis(plot, name, axis) do
    axis = %{axis | location: :bottom}
    axis = Axis2D.put_plot_id(axis, plot.id)
    new_axes = Map.put(plot.axes, name, axis)
    new_bottom = [{:axis_ref, name} | plot.bottom_content]

    %{plot | axes: new_axes, bottom_content: new_bottom}
  end

  def add_top_axis(plot, name, axis) do
    axis = %{axis | location: :top}
    axis = Axis2D.put_plot_id(axis, plot.id)
    new_axes = Map.put(plot.axes, name, axis)
    new_top = [{:axis_ref, name} | plot.top_content]

    %{plot | axes: new_axes, top_content: new_top}
  end

  def add_left_axis(plot, name, axis) do
    axis = %{axis | location: :left}
    axis = Axis2D.put_plot_id(axis, plot.id)
    new_axes = Map.put(plot.axes, name, axis)
    new_left = [{:axis_ref, name} | plot.left_content]

    %{plot | axes: new_axes, left_content: new_left}
  end

  def add_right_axis(plot, name, axis) do
    axis = %{axis | location: :right}
    axis = Axis2D.put_plot_id(axis, plot.id)
    new_axes = Map.put(plot.axes, name, axis)
    new_right = [{:axis_ref, name} | plot.right_content]

    %{plot | axes: new_axes, right_content: new_right}
  end

  def get_axis(plot, name) do
    Map.get(plot.axes, name)
  end

  def fetch_axis(plot, name) do
    Map.fetch(plot.axes, name)
  end

  def fetch_axis!(plot, name) do
    Map.fetch!(plot.axes, name)
  end

  def align_bbox(elements, fun) do
    for {e1, e2} <- Enum.zip(elements, Enum.drop(elements, 1)) do
      Figure.assert(fun.(e1) == fun.(e2))
    end
  end

  def align_top(elements), do: align_bbox(elements, &Sketch.bbox_top/1)
  def align_left(elements), do: align_bbox(elements, &Sketch.bbox_left/1)
  def align_right(elements), do: align_bbox(elements, &Sketch.bbox_right/1)
  def align_bottom(elements), do: align_bbox(elements, &Sketch.bbox_bottom/1)

  def stack_horizontally_inside_container(elements = [_first_element | _], container) do
    first = Enum.at(elements, 0)
    last = Enum.at(elements, -1)

    for {e1, e2} <- Enum.zip(elements, Enum.drop(elements, 1)) do
      Figure.assert(Sketch.bbox_right(e1) == Sketch.bbox_left(e2))
    end

    Figure.assert(Sketch.bbox_left(first) >= Sketch.bbox_left(container))
    Figure.assert(Sketch.bbox_right(last) <= Sketch.bbox_right(container))
  end

  def stack_vertically_inside_container(elements = [_first_element | _], container) do
    first = Enum.at(elements, 0)
    last = Enum.at(elements, -1)

    for {e1, e2} <- Enum.zip(elements, Enum.drop(elements, 1)) do
      Figure.assert(Sketch.bbox_bottom(e1) == Sketch.bbox_top(e2))
    end

    Figure.assert(Sketch.bbox_top(first) >= Sketch.bbox_top(container))
    Figure.assert(Sketch.bbox_bottom(last) <= Sketch.bbox_bottom(container))
  end

  def new(opts \\ []) do
    plot_id =
      case Keyword.fetch(opts, :id) do
        {:ok, id} -> id
        :error -> Figure.get_id()
      end

    top = Keyword.get(opts, :top, 0.0)
    bottom = Keyword.get(opts, :bottom, Figure.current_figure_height())
    left = Keyword.get(opts, :left, 0.0)
    right = Keyword.get(opts, :right, Figure.current_figure_height())

    plot_area = Canvas.new(prefix: "plot_area")
    title_area = Canvas.new(prefix: "title_area")
    data_area = Canvas.new(prefix: "data_area")
    top_decorations_area = Canvas.new(prefix: "top_decorations_area")
    top_right_decorations_area = Canvas.new(prefix: "top_right_decorations_area")
    right_decorations_area = Canvas.new(prefix: "right_decorations_area")
    bottom_right_decorations_area = Canvas.new(prefix: "bottom_right_decorations_area")
    bottom_decorations_area = Canvas.new(prefix: "bottom_decorations_area")
    bottom_left_decorations_area = Canvas.new(prefix: "bottom_left_decorations_area")
    left_decorations_area = Canvas.new(prefix: "left_decorations_area")
    top_left_decorations_area = Canvas.new(prefix: "top_left_decorations_area")

    left_areas = [
      top_left_decorations_area,
      left_decorations_area,
      bottom_left_decorations_area
    ]

    center_areas = [
      top_decorations_area,
      data_area,
      bottom_decorations_area
    ]

    right_areas = [
      top_right_decorations_area,
      right_decorations_area,
      bottom_right_decorations_area
    ]

    top_areas = [
      top_left_decorations_area,
      top_decorations_area,
      top_right_decorations_area
    ]

    horizon_areas = [
      left_decorations_area,
      data_area,
      right_decorations_area
    ]

    bottom_areas = [
      bottom_left_decorations_area,
      bottom_decorations_area,
      bottom_right_decorations_area
    ]

    # Make the plot_area fit tightly in the given space
    Figure.assert(Sketch.bbox_top(plot_area) == top)
    Figure.assert(Sketch.bbox_left(plot_area) == left)
    Figure.assert(Sketch.bbox_right(plot_area) == right)
    Figure.assert(Sketch.bbox_bottom(plot_area) == bottom)

    # Align areas by rows
    align_top(top_areas)
    align_bottom(top_areas)

    align_top(horizon_areas)
    align_bottom(horizon_areas)

    align_top(bottom_areas)
    align_bottom(bottom_areas)

    # Alin areas by columns
    align_left([title_area | left_areas])
    align_right(left_areas)

    align_left(center_areas)
    align_right(center_areas)

    align_left(right_areas)
    align_right(right_areas)

    # Figure.assert(Sketch.bbox_right(top_left_decorations_area) <= Sketch.bbox_left(top_decorations_area))
    # Figure.assert(top_left_decorations_area.x + top_left_decorations_area.width <= top_decorations_area.x)

    stack_horizontally_inside_container(top_areas, plot_area)
    stack_horizontally_inside_container(horizon_areas, plot_area)
    stack_horizontally_inside_container(bottom_areas, plot_area)

    stack_vertically_inside_container([title_area | left_areas], plot_area)
    stack_vertically_inside_container([title_area | center_areas], plot_area)
    stack_vertically_inside_container([title_area | right_areas], plot_area)

    Figure.assert(title_area.height >= Length.pt(8))
    Figure.assert(top_decorations_area.height >= Length.pt(8))
    Figure.assert(left_decorations_area.width >= Length.pt(8))
    Figure.assert(right_decorations_area.width >= Length.pt(8))
    Figure.assert(bottom_decorations_area.height >= Length.pt(8))

    Figure.maximize(data_area.width)
    Figure.maximize(data_area.height)

    Figure.minimize(title_area.height)
    Figure.minimize(top_decorations_area.height)
    Figure.minimize(bottom_decorations_area.height)
    Figure.minimize(right_decorations_area.width)
    Figure.minimize(left_decorations_area.width)

    axis_x = Axis2D.new("x", location: :bottom)
    axis_y = Axis2D.new("y", location: :left)
    axis_x2 = Axis2D.new("x2", location: :top)
    axis_y2 = Axis2D.new("y2", location: :right)

    plot = %__MODULE__{
      id: plot_id,
      title: nil,
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      plot_area: plot_area,
      title_area: title_area,
      data_area: data_area,
      top_decorations_area: top_decorations_area,
      top_right_decorations_area: top_right_decorations_area,
      right_decorations_area: right_decorations_area,
      bottom_right_decorations_area: bottom_right_decorations_area,
      bottom_decorations_area: bottom_decorations_area,
      bottom_left_decorations_area: bottom_left_decorations_area,
      left_decorations_area: left_decorations_area,
      top_left_decorations_area: top_left_decorations_area
    }

    plot
    |> add_bottom_axis("x", axis_x)
    |> add_left_axis("y", axis_y)
    |> add_top_axis("x2", axis_x2)
    |> add_right_axis("y2", axis_y2)
  end

  def put_axis_label(plot, axis_name, text, opts \\ []) do
    update_axis(plot, axis_name, fn axis ->
      Axis2D.put_label(axis, text, opts)
    end)
  end

  def update_axis(plot, axis_name, fun) do
    axis = Map.fetch!(plot.axes, axis_name)
    updated_axis = fun.(axis)
    new_axes = Map.put(plot.axes, axis_name, updated_axis)
    %{plot | axes: new_axes}
  end

  def put_title(plot, title, opts \\ []) do
    # Separate the text-related options from the other options
    {user_given_text_opts, opts} = Keyword.pop(opts, :text, [])
    # Merge the user-given text options with the default options for this figure
    text_opts = Config.get_plot_title_text_attributes(user_given_text_opts)

    # Handle the non-text-related options
    alignment = Keyword.get(opts, :alignment, :left)
    location = Keyword.get(opts, :location, :left)

    cond do
      is_binary(title) ->
        text = Text.new(title, text_opts)
        %{plot | title: text, title_location: location, title_alignment: alignment}

      # Find out how we should deal with this
      true ->
        %TypstAst{} = title
        %{plot | title: title, title_location: location, title_alignment: alignment}
    end
  end

  def finalize(plot) do
    :ok = Figure.put_plot_in_current_figure(plot)
    plot
  end

  def draw_bottom_content(plot) do
    x0 = plot.bottom_decorations_area.x
    y0 = plot.bottom_decorations_area.y

    Enum.reduce(plot.bottom_content, y0, fn element, y ->
      drawn =
        case element do
          {:axis_ref, name} ->
            axis = fetch_axis!(plot, name)
            Axis2D.draw_bottom_axis(plot, x0, y, axis)

          _ ->
            raise "Ooops"
        end

      Figure.assert(Sketch.bbox_top(drawn) >= Sketch.bbox_top(plot.bottom_decorations_area))
      Figure.assert(Sketch.bbox_bottom(drawn) <= Sketch.bbox_bottom(plot.bottom_decorations_area))

      Sketch.bbox_bottom(drawn)
    end)
  end

  def draw_top_content(plot) do
    x0 = plot.top_decorations_area.x
    y0 = Sketch.bbox_bottom(plot.top_decorations_area)

    Enum.reduce(plot.top_content, y0, fn element, y ->
      drawn =
        case element do
          {:axis_ref, name} ->
            axis = fetch_axis!(plot, name)
            Axis2D.draw_top_axis(plot, x0, y, axis)

          _ ->
            raise "Ooops"
        end

      Figure.assert(Sketch.bbox_top(drawn) >= Sketch.bbox_top(plot.top_decorations_area))
      Figure.assert(Sketch.bbox_bottom(drawn) <= Sketch.bbox_bottom(plot.top_decorations_area))

      y - Sketch.bbox_height(drawn)
    end)
  end

  def draw_left_content(plot) do
    x0 = Sketch.bbox_right(plot.left_decorations_area)
    y0 = plot.left_decorations_area.y

    Enum.reduce(plot.left_content, x0, fn element, x ->
      drawn =
        case element do
          {:axis_ref, name} ->
            axis = fetch_axis!(plot, name)
            Axis2D.draw_left_axis(plot, x, y0, axis)

          _ ->
            raise "Ooops"
        end

      Figure.assert(Sketch.bbox_left(drawn) >= Sketch.bbox_left(plot.left_decorations_area))
      Figure.assert(Sketch.bbox_right(drawn) <= Sketch.bbox_right(plot.left_decorations_area))

      x - Sketch.bbox_width(drawn)
    end)
  end

  def draw_right_content(plot) do
    x0 = plot.right_decorations_area.x
    y0 = plot.right_decorations_area.y

    Enum.reduce(plot.right_content, x0, fn element, x ->
      drawn =
        case element do
          {:axis_ref, name} ->
            axis = fetch_axis!(plot, name)
            Axis2D.draw_right_axis(plot, x, y0, axis)

          _ ->
            raise "Ooops"
        end

      Figure.assert(Sketch.bbox_left(drawn) >= Sketch.bbox_left(plot.right_decorations_area))
      Figure.assert(Sketch.bbox_right(drawn) <= Sketch.bbox_right(plot.right_decorations_area))

      x + Sketch.bbox_width(drawn)
    end)
  end

  def draw_title(plot) do
    if plot.title do
      Figure.position_with_location_and_alignment(
        plot.title,
        plot.title_area,
        x_location: :left,
        y_location: :bottom,
        y_offset: -plot.title_inner_padding,
        contains_vertically?: true
      )
    end

    :ok
  end

  def draw(plot) do
    draw_title(plot)
    draw_left_content(plot)
    draw_top_content(plot)
    draw_right_content(plot)
    draw_bottom_content(plot)
  end

  def boxplot(plot, _data) do
    plot
  end

  def example() do
    use Dantzig.Polynomial.Operators
    alias Quartz.Figure
    alias Quartz.Plot2D
    alias Quartz.Length

    figure =
      Figure.new([width: Length.cm(16), height: Length.cm(6)], fn fig ->
        figure_width = fig.width

        _plot_task_A =
          Plot2D.new(id: "plot_task_A", left: 0.0, right: 0.55 * figure_width)
          |> Plot2D.boxplot(nil)
          # Use typst to explicitly style the title and labels ――――――――――――――――――――――――――――――――
          |> Plot2D.put_title("A. Task A")
          |> Plot2D.put_axis_label("y", "Y-label")
          |> Plot2D.put_axis_label("x2", "X2-label")
          |> Plot2D.put_axis_label("x", "X-label without $math$")
          |> Plot2D.finalize()

        _plot_task_B =
          Plot2D.new(id: "plot_task_B", left: 0.55 * figure_width + Length.pt(8), right: figure_width)
          |> Plot2D.boxplot(nil)
          # Use typst to explicitly style the title and labels ――――――――――――――――――――――――――――――――
          |> Plot2D.put_title("B. Task B")
          |> Plot2D.put_axis_label("y", "Y-label")
          |> Plot2D.put_axis_label("x2", "X2-label")
          |> Plot2D.put_axis_label("x", "X-label (with  math: $x^2 + y^2$)", text: [escape: false])
          |> Plot2D.finalize()
      end)

    Figure.render_to_pdf!(figure, "example.pdf")
  end
end
