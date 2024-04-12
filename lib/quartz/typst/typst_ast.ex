defmodule Quartz.Typst.TypstAst do
  alias Quartz.Typst.TypstValue
  alias Quartz.Typst.TypstAst

  defstruct kind: nil,
            data: %{}

  def raw(content) when is_binary(content) do
    %TypstAst{kind: :raw, data: %{content: content}}
  end

  def pt(value) when is_integer(value) do
    raw("#{value}pt")
  end

  def pt(value) when is_float(value) do
    rounded_float = Float.round(value, 3)
    raw("#{rounded_float}pt")
  end

  def sequence(items) when is_list(items) do
    %TypstAst{kind: :sequence, data: %{items: items}}
  end

  def integer(value) when is_integer(value) do
    %TypstAst{kind: :integer, data: %{value: value}}
  end

  def float(value) when is_float(value) do
    %TypstAst{kind: :float, data: %{value: value}}
  end

  def string(value) when is_binary(value) do
    %TypstAst{kind: :string, data: %{value: value}}
  end

  def variable(name) when is_atom(name) or is_binary(name) do
    %TypstAst{kind: :variable, data: %{name: name}}
  end

  def function_call(function, arguments) do
    %TypstAst{
      kind: :function_call,
      data: %{
        function: TypstValue.to_typst(function),
        arguments: Enum.map(arguments, &function_argument_to_typst/1)
      }
    }
  end

  def method_call(object, method, arguments) when is_binary(method) or is_atom(method) do
    %TypstAst{
      kind: :method_call,
      data: %{
        object: TypstValue.to_typst(object),
        method: to_string(method),
        arguments: Enum.map(arguments, &function_argument_to_typst/1)
      }
    }
  end

  defp function_argument_to_typst({name, value}) when is_binary(name) or is_atom(name) do
    named_argument(to_string(name), TypstValue.to_typst(value))
  end

  defp function_argument_to_typst(argument) do
    TypstValue.to_typst(argument)
  end

  def named_argument(name, value) when is_binary(name) or is_atom(name) do
    %TypstAst{
      kind: :named_argument,
      data: %{
        name: to_string(name),
        value: TypstValue.to_typst(value)
      }
    }
  end

  def named_arguments_from_map(map) do
    # Ensure deterministic order of the map elements
    items = Enum.sort(map)

    for {name, value} <- items do
      named_argument(name, value)
    end
  end

  def named_arguments_from_proplist(proplist) do
    for {name, value} <- proplist do
      named_argument(name, value)
    end
  end

  def operator(op, left, right) do
    %TypstAst{
      kind: :operator,
      data: %{
        operator: op,
        left: TypstValue.to_typst(left),
        right: TypstValue.to_typst(right)
      }
    }
  end

  def array(items) when is_list(items) do
    typst_items = Enum.map(items, fn item -> TypstValue.to_typst(item) end)
    %TypstAst{kind: :array, data: %{items: typst_items}}
  end

  def dictionary(items) when is_map(items) or is_list(items) do
    typst_items = Enum.map(items, fn {k, v} -> {to_string(k), TypstValue.to_typst(v)} end)
    %TypstAst{kind: :dictionary, data: %{items: typst_items}}
  end

  def let(pattern, value) do
    %TypstAst{kind: :let, data: %{pattern: pattern, value: value}}
  end

  def place(x, y, content) do
    function_call(
      variable("place"),
      [TypstAst.raw("top + left")] ++
        named_arguments_from_proplist(
          dx: pt(x),
          dy: pt(y)
        ) ++ [content]
    )
  end

  def example() do
    let(variable("x"), operator("+", variable("x"), variable("y")))
  end
end
