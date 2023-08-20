defmodule Quartz.Line do
  alias Quartz.Figure
  alias Quartz.Variable

  defstruct id: nil,
            x1: nil,
            y1: nil,
            x2: nil,
            y2: nil

  def new(opts \\ []) do
    prefix = Keyword.get(opts, :prefix, nil)
    # Assign variables (= Dantzig monomials) to the parameters of the line
    x1 = Variable.maybe_variable(opts, :x1, Variable.maybe_with_prefix(prefix, "line_x1"), [])
    y1 = Variable.maybe_variable(opts, :y1, Variable.maybe_with_prefix(prefix, "line_y1"), [])
    x2 = Variable.maybe_variable(opts, :x2, Variable.maybe_with_prefix(prefix, "line_x2"), [])
    y2 = Variable.maybe_variable(opts, :y2, Variable.maybe_with_prefix(prefix, "line_y2"), [])

    # Get the next available ID from the figure
    id = Figure.get_id()
    # Create the actual line
    line = %__MODULE__{id: id, x1: x1, y1: y1, x2: x2, y2: y2}
    # Add the line to the figure
    Figure.add_sketch(id, line)
    # Return the line, with no reference to the figure
    line
  end

  defimpl Quartz.Sketch do
    use Dantzig.Polynomial.Operators
    alias Quartz.Point2D

    defp horizontal_center(line) do
      (line.x1 + line.x2) * 0.5
    end

    defp vertical_center(line) do
      (line.y1 + line.y2) * 0.5
    end

    @impl true
    def top_center(line) do
      %Point2D{
        x: horizontal_center(line),
        y: line.y
      }
    end

    @impl true
    def top_right(line) do
      %Point2D{
        x: line.x2,
        y: line.y1
      }
    end

    @impl true
    def horizon_right(line) do
      %Point2D{
        x: line.x2,
        y: vertical_center(line)
      }
    end

    @impl true
    def bottom_right(line) do
      %Point2D{
        x: line.x2,
        y: line.y2
      }
    end

    @impl true
    def bottom_center(line) do
      %Point2D{
        x: horizontal_center(line),
        y: line.y2
      }
    end

    @impl true
    def bottom_left(line) do
      %Point2D{
        x: line.x1,
        y: line.y2
      }
    end

    @impl true
    def horizon_left(line) do
      %Point2D{
        x: line.x1,
        y: vertical_center(line)
      }
    end

    @impl true
    def top_left(line) do
      %Point2D{
        x: line.x1,
        y: line.y1
      }
    end

    @impl true
    def bbox_center(line) do
      0.5 * (bbox_left(line) + bbox_right(line))
    end

    @impl true
    def bbox_horizon(line) do
      0.5 * (bbox_top(line) + bbox_bottom(line))
    end

    @impl true
    def bbox_top(line) do
      line.y1
    end

    @impl true
    def bbox_left(line) do
      line.x1
    end

    @impl true
    def bbox_right(line) do
      line.x2
    end

    @impl true
    def bbox_bottom(line) do
      line.y2
    end

    @impl true
    def bbox_height(line) do
      bbox_bottom(line) - bbox_top(line)
    end

    @impl true
    def bbox_width(line) do
      bbox_right(line) - bbox_left(line)
    end

    @impl true
    def lengths(line) do
      [line.x1, line.y1, line.x2, line.y2]
    end

    @impl true
    def solve(line) do
      solved_x = Figure.solve!(line.x1)
      solved_y = Figure.solve!(line.y1)
      solved_x2 = Figure.solve!(line.x2)
      solved_y2 = Figure.solve!(line.y2)

      %{line | x1: solved_x, y1: solved_y, x2: solved_x2, y2: solved_y2}
    end

    alias Quartz.Typst.TypstAst

    @impl true
    def to_typst(line) do
      typst_line = TypstAst.function_call(
        TypstAst.variable("line"),
        TypstAst.named_arguments_from_proplist(
          start: TypstAst.array([
            TypstAst.pt(line.x1),
            TypstAst.pt(line.y1)
          ]),
          end: TypstAst.array([
            TypstAst.pt(line.x2),
            TypstAst.pt(line.y2)
          ])
        )
      )

      TypstAst.place(0, 0, typst_line)
    end
  end
end
