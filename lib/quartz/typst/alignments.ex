defmodule Quartz.Typst.Alignments do
  alias Quartz.Typst.TypstAst

  def top(), do: TypstAst.variable("top")
  def horizon(), do: TypstAst.variable("horizon")
  def bottom(), do: TypstAst.variable("bottom")

  def start(), do: TypstAst.variable("start")
  def end_(), do: TypstAst.variable("end")
  def center(), do: TypstAst.variable("center")
  def left(), do: TypstAst.variable("left")
  def right(), do: TypstAst.variable("right")
end
