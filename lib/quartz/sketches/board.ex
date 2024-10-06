defmodule Quartz.Board do
  @moduledoc false

  alias Quartz.Sketch
  alias Quartz.Config
  alias Quartz.Board.BoardDebugProperties
  require Quartz.Figure, as: Figure
  require Quartz.KeywordSpec, as: KeywordSpec
  import Quartz.Operators, only: [algebra: 1]
  alias Dantzig.Polynomial

  defstruct id: nil,
            x: nil,
            y: nil,
            height: nil,
            width: nil,
            prefix: nil,
            debug: nil,
            debug_properties: nil,
            panels: []

  def new(attrs) do
    KeywordSpec.validate!(attrs, [
      !panels,
      width: 0,
      height: 0,
      x: Figure.variable("board_x"),
      y: Figure.variable("board_y"),
      maximize_width: false,
      maximize_height: false
    ])

    minimize_width = not maximize_width
    minimize_height = not maximize_height

    board_width = Figure.variable("board_width")
    board_height = Figure.variable("board_height")

    if minimize_width do
      Figure.assert(board_width >= width)
      Figure.minimize(board_width)
    else
      Figure.assert(board_width <= width)
      Figure.maximize(board_width)
    end

    if minimize_height do
      Figure.assert(board_height >= height)
      Figure.minimize(board_height)
    else
      Figure.assert(board_height <= height)
      Figure.maximize(board_height)
    end

    width_in_cells =
      panels
      |> Enum.map(fn panel -> panel.right_index end)
      |> Enum.max()
      |> Kernel.+(1)

    height_in_cells =
      panels
      |> Enum.map(fn panel -> panel.bottom_index end)
      |> Enum.max()
      |> Kernel.+(1)

    cell_widths =
      for i <- 1..width_in_cells do
        Figure.variable("cell_width_#{i}", min: 0.0)
      end

    cell_heights =
      for i <- 1..height_in_cells do
        Figure.variable("cell_height_#{i}", min: 0.0)
      end

    mean_cell_width = algebra(Polynomial.sum(cell_widths) / width_in_cells)
    mean_cell_height = algebra(Polynomial.sum(cell_heights) / height_in_cells)

    for cell_width <- cell_widths do
      if minimize_width do
        Figure.minimize(cell_width)
      else
        Figure.maximize(cell_width)
      end

      # All else being equal, cells should be the same width
      Figure.minimize(abs(cell_width - mean_cell_width))
    end

    for cell_height <- cell_heights do
      if minimize_height do
        Figure.minimize(cell_height)
      else
        Figure.maximize(cell_height)
      end

      # All else being equal, cells should be the same height
      Figure.minimize(abs(cell_height - mean_cell_height))
    end

    for panel <- panels do
      offset_x =
        cell_widths
        |> Enum.slice(0, panel.left_index)
        |> Polynomial.sum()

      offset_y =
        cell_heights
        |> Enum.slice(0, panel.top_index)
        |> Polynomial.sum()

      panel_x = algebra(x + offset_x)

      panel_y = algebra(y + offset_y)

      panel_width =
        cell_widths
        |> Enum.slice(panel.left_index, panel.right_index - panel.left_index + 1)
        |> Polynomial.sum()

      panel_height =
        cell_heights
        |> Enum.slice(panel.top_index, panel.bottom_index - panel.top_index + 1)
        |> Polynomial.sum()

      Figure.assert(panel.canvas.x == panel_x + panel.padding_left)
      Figure.assert(panel.canvas.y == panel_y + panel.padding_top)
      Figure.assert(panel.canvas.width == panel_width - panel.padding_right - panel.padding_left)

      Figure.assert(
        panel.canvas.height == panel_height - panel.padding_bottom - panel.padding_top
      )
    end

    Figure.assert(board_width == Polynomial.sum(cell_widths))
    Figure.assert(board_height == Polynomial.sum(cell_heights))

    # Get the next available ID from the figure
    id = Figure.get_id()

    debug = Figure.debug?()

    debug_properties =
      if debug do
        Config.get_board_debug_properties()
      else
        nil
      end

    board =
      %__MODULE__{
        id: id,
        width: board_width,
        height: board_height,
        panels: panels,
        x: x,
        y: y,
        debug: debug,
        debug_properties: debug_properties
      }

    board
  end

  def draw_new(opts \\ []) do
    board = new(opts)
    Sketch.draw(board)
    board
  end

  defimpl Quartz.Sketch.Protocol do
    require Dantzig.Polynomial, as: Polynomial
    alias Quartz.Formatter
    alias Quartz.SVG
    alias Quartz.Sketch.BBoxBounds
    alias Quartz.Board.BoardDebugProperties

    @impl true
    def bbox_bounds(board) do
      %BBoxBounds{
        x_min: board.x,
        x_max: Polynomial.algebra(board.x + board.width),
        y_min: board.y,
        y_max: Polynomial.algebra(board.y + board.height)
      }
    end

    @impl true
    def lengths(board) do
      [board.x, board.y, board.width, board.height]
    end

    @impl true
    def transform_lengths(board, fun) do
      transformed_x = fun.(board.x)
      transformed_y = fun.(board.y)
      transformed_width = fun.(board.width)
      transformed_height = fun.(board.height)

      debug_properties =
        case board.debug_properties do
          %BoardDebugProperties{} ->
            %{
              board.debug_properties
              | stroke_width: fun.(board.debug_properties.stroke_width)
            }

          other ->
            other
        end

      %{
        board
        | x: transformed_x,
          y: transformed_y,
          width: transformed_width,
          height: transformed_height,
          debug_properties: debug_properties
      }
    end

    @impl true
    def to_unpositioned_svg(board) do
      to_svg(board)
    end

    @impl true
    def to_svg(board) do
      if board.debug do
        # Get some extra attributes for our rectangle
        debug_attrs = BoardDebugProperties.to_svg_attributes(board.debug_properties)

        rect_attrs = [
          id: board.id,
          x: board.x,
          y: board.y,
          width: board.width,
          height: board.height
        ]

        all_attrs = rect_attrs ++ debug_attrs

        tooltip_text = [
          "Board [#{board.id}] #{board.prefix} &#13;",
          "&#160;↳&#160;x = #{Formatter.rounded_float(board.x, 2)}pt&#13;",
          "&#160;↳&#160;y = #{Formatter.rounded_float(board.y, 2)}pt&#13;",
          "&#160;↳&#160;width = #{Formatter.rounded_float(board.width, 2)}pt&#13;",
          "&#160;↳&#160;height = #{Formatter.rounded_float(board.height, 2)}pt"
        ]

        SVG.rect(all_attrs, [
          SVG.title([], SVG.escaped_iodata(tooltip_text))
        ])
      else
        SVG.g([id: board.id], [])
      end
    end
  end
end
