defprotocol Quartz.Plot2DElement do
  alias Dantzig.Polynomial
  alias Quartz.Plot2D

  @spec draw(t(), Plot2D.t(), Polynomial.t() | number(), Polynomial.t() | number()) :: any()
  def draw(element, plot, x, y)
end
