defimpl Quartz.Typst.TypstValue, for: Integer do
  alias Quartz.Typst.TypstAst

  def to_typst(integer), do: TypstAst.integer(integer)
end

defimpl Quartz.Typst.TypstValue, for: Float do
  alias Quartz.Typst.TypstAst

  def to_typst(float), do: TypstAst.float(float)
end

defimpl Quartz.Typst.TypstValue, for: String do
  alias Quartz.Typst.TypstAst

  def to_typst(string), do: TypstAst.string(string)
end

defimpl Quartz.Typst.TypstValue, for: BitString do
  alias Quartz.Typst.TypstAst

  def to_typst(string), do: TypstAst.string(string)
end

defimpl Quartz.Typst.TypstValue, for: Atom do
  alias Quartz.Typst.TypstAst

  def to_typst(nil), do: TypstAst.variable("none")
  def to_typst(atom), do: atom |> to_string() |> TypstAst.variable()
end

defimpl Quartz.Typst.TypstValue, for: Map do
  alias Quartz.Typst.TypstAst

  def to_typst(map) do
    items =
      for {key, value} <- map do
        string_key = to_string(key)
        {string_key, value}
      end

    # Sort the items deterministic output.
    # Equal dictionaries should always be converted into equal Typst AST.
    items
    |> Enum.sort()
    |> TypstAst.dictionary()
  end
end

defimpl Quartz.Typst.TypstValue, for: List do
  alias Quartz.Typst.TypstAst

  def to_typst(list) do
    TypstAst.array(list)
  end
end

defimpl Quartz.Typst.TypstValue, for: Quartz.Color.RGB do
  alias Quartz.Color.RGB
  alias Quartz.Typst.TypstAst

  def to_typst(%RGB{} = rgb) do
    TypstAst.function_call(
      TypstAst.variable("rgb"),
      [rgb.red, rgb.green, rgb.blue, rgb.alpha]
    )
  end
end

defimpl Quartz.Typst.TypstValue, for: Quartz.Typst.TypstAst do
  alias Quartz.Typst.TypstAst

  def to_typst(%TypstAst{} = typst_ast) do
    typst_ast
  end
end
