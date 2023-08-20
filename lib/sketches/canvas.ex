defmodule Quartz.Canvas do
  alias Quartz.Figure
  alias Quartz.Variable

  defstruct id: nil,
            x: nil,
            y: nil,
            width: nil,
            height: nil

  def new(opts \\ []) do
    prefix = Keyword.get(opts, :prefix, nil)
    # Assign variables (= Dantzig monomials) to the parameters of the canvas
    x = Variable.maybe_variable(opts, :x, Variable.maybe_with_prefix(prefix, "canvas_x"), [])
    y = Variable.maybe_variable(opts, :y, Variable.maybe_with_prefix(prefix, "canvas_y"), [])

    height =
      Variable.maybe_variable(opts, :height, Variable.maybe_with_prefix(prefix, "canvas_height"),
        min: 0
      )

    width =
      Variable.maybe_variable(opts, :width, Variable.maybe_with_prefix(prefix, "canvas_width"),
        min: 0
      )

    # Get the next available ID from the figure
    id = Figure.get_id()
    # Create the actual canvas
    canvas = %__MODULE__{id: id, x: x, y: y, height: height, width: width}
    # Add the canvas to the figure
    Figure.add_sketch(id, canvas)
    # Return the canvas, with no reference to the figure
    canvas
  end

  defimpl Quartz.Sketch do
    use Dantzig.Polynomial.Operators
    alias Quartz.Point2D
    alias Quartz.Color.RGB

    def to_color_component(float_between_0_and_1) do
      trunc(Kernel.+(64, Kernel.*(float_between_0_and_1, 191)))
    end

    def pseudorandom_color(id) do
      n1 = rem(Kernel.*(id, 172), 897_577)
      n2 = rem(Kernel.*(id, 7872), 543_566)
      n3 = rem(Kernel.*(id, 971), 228_798)

      s0 = :rand.seed_s(:exsss, {n1, n2, n3})
      {r, s1} = :rand.uniform_s(s0)
      {g, s2} = :rand.uniform_s(s1)
      {b, _s3} = :rand.uniform_s(s2)

      red = to_color_component(r)
      green = to_color_component(g)
      blue = to_color_component(b)

      %RGB{red: red, green: green, blue: blue, alpha: 64}
    end

    defp horizontal_center(canvas) do
      (canvas.x + canvas.width) * 0.5
    end

    defp vertical_center(canvas) do
      (canvas.y + canvas.height) * 0.5
    end

    @impl true
    def top_center(canvas) do
      %Point2D{
        x: horizontal_center(canvas),
        y: canvas.y
      }
    end

    @impl true
    def top_right(canvas) do
      %Point2D{
        x: canvas.x + canvas.width,
        y: canvas.y
      }
    end

    @impl true
    def horizon_right(canvas) do
      %Point2D{
        x: canvas.x + canvas.width,
        y: vertical_center(canvas)
      }
    end

    @impl true
    def bottom_right(canvas) do
      %Point2D{
        x: canvas.x + canvas.width,
        y: canvas.y + canvas.height
      }
    end

    @impl true
    def bottom_center(canvas) do
      %Point2D{
        x: horizontal_center(canvas),
        y: canvas.y + canvas.height
      }
    end

    @impl true
    def bottom_left(canvas) do
      %Point2D{
        x: canvas.x,
        y: canvas.y + canvas.height
      }
    end

    @impl true
    def horizon_left(canvas) do
      %Point2D{
        x: canvas.x,
        y: vertical_center(canvas)
      }
    end

    @impl true
    def top_left(canvas) do
      %Point2D{
        x: canvas.x,
        y: canvas.y + canvas.height
      }
    end

    @impl true
    def bbox_center(canvas) do
      0.5 * (bbox_left(canvas) + bbox_right(canvas))
    end

    @impl true
    def bbox_horizon(canvas) do
      0.5 * (bbox_top(canvas) + bbox_bottom(canvas))
    end

    @impl true
    def bbox_top(canvas) do
      canvas.y
    end

    @impl true
    def bbox_left(canvas) do
      canvas.x
    end

    @impl true
    def bbox_right(canvas) do
      canvas.x + canvas.width
    end

    @impl true
    def bbox_bottom(canvas) do
      canvas.y + canvas.height
    end

    @impl true
    def bbox_height(canvas) do
      bbox_bottom(canvas) - bbox_top(canvas)
    end

    @impl true
    def bbox_width(canvas) do
      bbox_right(canvas) - bbox_left(canvas)
    end

    @impl true
    def lengths(canvas) do
      [canvas.x, canvas.y, canvas.width, canvas.height]
    end

    @impl true
    def solve(canvas) do
      solved_x = Figure.solve!(canvas.x)
      solved_y = Figure.solve!(canvas.y)
      solved_width = Figure.solve!(canvas.width)
      solved_height = Figure.solve!(canvas.height)

      %{canvas | x: solved_x, y: solved_y, width: solved_width, height: solved_height}
    end

    alias Quartz.Typst.TypstAst

    @impl true
    def to_typst(canvas) do
      box =
        TypstAst.function_call(
          TypstAst.variable("rect"),
          TypstAst.named_arguments_from_proplist(
            stroke: TypstAst.dictionary([
              thickness: TypstAst.pt(0.75),
              paint: TypstAst.variable("gray"),
              dash: TypstAst.string("dotted")
            ]),
            width: TypstAst.pt(canvas.width),
            height: TypstAst.pt(canvas.height)
          )
        )

      TypstAst.place(
        canvas.x,
        canvas.y,
        box
      )
    end
  end
end
