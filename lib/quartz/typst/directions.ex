defmodule Quartz.Typst.Directons do
  alias Quartz.Typst.TypstAst

  def ltr(), do: TypstAst.variable("ltr")
  def rtl(), do: TypstAst.variable("rtl")
  def ttb(), do: TypstAst.variable("ttb")
  def btt(), do: TypstAst.variable("btt")
end
