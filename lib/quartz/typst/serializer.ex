defmodule Quartz.Typst.Serializer do
  alias Quartz.Typst.TypstAst

  @indent_advancement 2

  defp spaces(indent), do: String.duplicate(" ", indent)

  def serialize(ast) do
    serialize(ast, 0) |> IO.iodata_to_binary()
  end

  def serialize(%TypstAst{kind: :raw, data: %{content: content}}, _indent) do
    content
  end

  def serialize(%TypstAst{kind: :sequence, data: %{items: items}}, indent) do
    inner_spaces = spaces(indent)

    items
    |> Enum.map(fn item -> serialize(item, indent) end)
    |> Enum.intersperse([" +\n", inner_spaces])
  end

  def serialize(%TypstAst{kind: :integer, data: %{value: value}}, _indent) do
    to_string(value)
  end

  def serialize(%TypstAst{kind: :float, data: %{value: value}}, _indent) do
    to_string(value)
  end

  def serialize(%TypstAst{kind: :string, data: %{value: value}}, _indent) do
    inspect(value, limit: :infinity)
  end

  def serialize(%TypstAst{kind: :variable, data: %{name: name}}, _indent) do
    to_string(name)
  end

  def serialize(%TypstAst{kind: :operator, data: data}, indent) do
    %{operator: op, left: left, right: right} = data

    [
      serialize(left, indent),
      " ",
      op,
      " ",
      serialize(right, indent)
    ]
  end

  def serialize(%TypstAst{kind: :let, data: %{pattern: pattern, value: value}}, indent) do
    [
      "let ",
      serialize(pattern, indent + @indent_advancement),
      " = ",
      serialize(value, indent + @indent_advancement),
      "\n"
    ]
  end

  def serialize(%TypstAst{kind: :method_call, data: data}, indent) do
    %{object: object, method: method, arguments: arguments} = data

    call_spaces = spaces(indent)
    arg_spaces = spaces(indent + @indent_advancement)

    call = [serialize(object, indent), ".", method, "("]

    serialized_args =
      for arg <- arguments do
        [arg_spaces, serialize(arg, indent + @indent_advancement)]
      end

    comma_separated_args = Enum.intersperse(serialized_args, ",\n")

    close_parenthesis = [call_spaces, ")"]

    [
      call,
      "\n",
      comma_separated_args,
      "\n",
      close_parenthesis
    ]
  end

  def serialize(%TypstAst{kind: :function_call, data: data}, indent) do
    %{function: function, arguments: arguments} = data

    call_spaces = spaces(indent)
    arg_spaces = spaces(indent + @indent_advancement)

    call = [serialize(function, indent), "("]

    serialized_args =
      for arg <- arguments do
        [arg_spaces, serialize(arg, indent + @indent_advancement)]
      end

    comma_separated_args = Enum.intersperse(serialized_args, ",\n")

    close_parenthesis = [call_spaces, ")"]

    [
      call,
      "\n",
      comma_separated_args,
      "\n",
      close_parenthesis
    ]
  end

  def serialize(%TypstAst{kind: :named_argument, data: %{name: name, value: value}}, indent) do
    [
      name,
      ": ",
      serialize(value, indent + @indent_advancement)
    ]
  end

  def serialize(%TypstAst{kind: :dictionary, data: %{items: items}}, indent) do
    dict_spaces = spaces(indent)
    items_spaces = spaces(indent + @indent_advancement)

    serialized_items =
      for {key, value} <- items do
        safe_key = inspect(key)
        [items_spaces, safe_key, ": ", serialize(value, indent + @indent_advancement)]
      end

    comma_separated_args = Enum.intersperse(serialized_items, ",\n")

    [
      "(\n",
      comma_separated_args,
      "\n",
      dict_spaces,
      ")"
    ]
  end

  def serialize(%TypstAst{kind: :array, data: %{items: items}}, indent) do
    array_spaces = spaces(indent)
    items_spaces = spaces(indent + @indent_advancement)

    serialized_items =
      Enum.map(items, fn item ->
        [items_spaces, serialize(item, indent + @indent_advancement)]
      end)

    # Trailing comma to avoid confusion between (x) and (x,)
    comma_separated_args = Enum.map(serialized_items, fn item -> [item, ",\n"] end)

    [
      "(\n",
      comma_separated_args,
      array_spaces,
      ")"
    ]
  end
end
