defprotocol Quartz.Typst.TypstValue do
  @spec to_unpositioned_typst(t) :: any()
  def to_unpositioned_typst(value)

  @spec to_typst(t) :: any()
  def to_typst(value)
end
