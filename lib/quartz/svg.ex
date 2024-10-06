defmodule Quartz.SVG do
  @moduledoc """
  Utilities to work with SVG elements.
  """

  alias Quartz.Color.RGB
  import Quartz.Utilities, only: [display_rounded_float: 1]

  @typedoc """
  An SVG element is represented by
  """
  @type t :: {binary(), list(), list()}

  @doc false
  defmacrop handle_units_of_measurement(attrs, attrs_with_units) do
    attrs_with_units_binaries =
      for attr <- attrs_with_units do
        to_string(attr)
      end

    attrs_with_units_atoms =
      for attr <- attrs_with_units_binaries do
        String.to_atom(attr)
      end

    all_attrs_with_units = attrs_with_units_binaries ++ attrs_with_units_atoms

    quote do
      for {key, value} <- unquote(attrs) do
        case key do
          attr_with_units when is_number(value) and key in unquote(all_attrs_with_units) ->
            {key, "#{value}px"}

          _other ->
            {key, value}
        end
      end
    end
  end

  @doc """
  SVG `<g/>` element.
  """
  def g(attrs, contents) do
    {"g", attrs, contents}
  end

  @doc """
  SVG `<text/>` element.
  """
  def text(attrs, content) do
    attrs = handle_units_of_measurement(attrs, [:x, :y, :width, :height])
    contents = List.wrap(content)

    escaped_contents =
      for fragment <- contents do
        case fragment do
          binary when is_binary(binary) ->
            xml_escape_to_iodata(binary)

          other ->
            other
        end
      end

    {"text", attrs, escaped_contents}
  end

  @doc """
  SVG `<tspan/>` element.
  """
  def tspan(attrs, content) do
    contents = List.wrap(content)

    escaped_contents =
      for fragment <- contents do
        case fragment do
          binary when is_binary(binary) ->
            xml_escape_to_iodata(binary)

          other ->
            other
        end
      end

    {"tspan", attrs, escaped_contents}
  end

  @doc """
  SVG `<title/>` element.

  This element is not rendered but is very useful for debugging.
  It can be used to show properties of the containing element.
  """
  def title(attrs, content) do
    wrapped_content = List.wrap(content)
    {"title", attrs, wrapped_content}
  end

  @doc """
  Build a top level SVG element.
  """
  def svg(attrs, contents) do
    # The width and height will be in pts.
    # If we make the viewPort width == to the SVG width
    # and the viewPort height == to the SVG height, then
    # each unitless value will correspond to the value in pts.
    {width, attrs} = Keyword.pop(attrs, :width)
    {height, attrs} = Keyword.pop(attrs, :height)

    first_attrs = [
      {"xmlns", "http://www.w3.org/2000/svg"},
      width: "#{display_rounded_float(width)}pt",
      height: "#{display_rounded_float(height)}pt"
    ]

    {"svg", first_attrs ++ attrs, contents}
  end

  @doc """
  Build a path.
  """
  def path(attrs, content \\ []) do
    wrapped_content = List.wrap(content)
    {points, attrs} = Keyword.pop(attrs, :d, [])
    new_attrs = [{"d", points_to_iodata(points)} | attrs]
    {"path", new_attrs, wrapped_content}
  end

  defp points_to_iodata(points), do: Enum.map(points, &point_to_iodata/1)

  # Move to point without drawing a line
  defp point_to_iodata({:M, {x, y}}),
    do: ["M ", display_rounded_float(x), " ", display_rounded_float(y)]

  defp point_to_iodata({:m, {dx, dy}}),
    do: ["m ", display_rounded_float(dx), " ", display_rounded_float(dy)]

  # Draw a line from the last point to the current point
  defp point_to_iodata({:L, {x, y}}),
    do: ["L ", display_rounded_float(x), " ", display_rounded_float(y)]

  defp point_to_iodata({:l, {dx, dy}}),
    do: ["l ", display_rounded_float(dx), " ", display_rounded_float(dy)]

  # Horizontal line
  defp point_to_iodata({:H, x}), do: ["H ", display_rounded_float(x)]
  defp point_to_iodata({:h, dx}), do: ["h ", display_rounded_float(dx)]
  # Vertical line
  defp point_to_iodata({:V, y}), do: ["V ", display_rounded_float(y)]
  defp point_to_iodata({:v, dy}), do: ["v ", display_rounded_float(dy)]
  # Bezier curves
  defp point_to_iodata({:C, {x1, y1, x2, y2, x, y}}),
    do: [
      "C ",
      display_rounded_float(x1),
      display_rounded_float(y1),
      ", ",
      display_rounded_float(x2),
      display_rounded_float(y2),
      ", ",
      display_rounded_float(x),
      display_rounded_float(y)
    ]

  defp point_to_iodata({:c, {dx1, dy1, dx2, dy2, dx, dy}}),
    do: [
      "c ",
      display_rounded_float(dx1),
      display_rounded_float(dy1),
      ", ",
      display_rounded_float(dx2),
      display_rounded_float(dy2),
      ", ",
      display_rounded_float(dx),
      display_rounded_float(dy)
    ]

  defp point_to_iodata(z) when z in [:z, :Z] do
    "z"
  end

  @doc """
  SVG `<rect/>` element.
  """
  def rect(attrs, content \\ []) do
    wrapped_content = List.wrap(content)
    attrs = handle_units_of_measurement(attrs, [:x, :y, :width, :height])
    {"rect", attrs, wrapped_content}
  end

  @doc """
  SVG `<circle/>` element.
  """
  def circle(attrs, content \\ []) do
    wrapped_content = List.wrap(content)
    attrs = handle_units_of_measurement(attrs, [:cx, :cy, :r])
    {"circle", attrs, wrapped_content}
  end

  @doc """
  SVG `<line/>` element.
  """
  def line(attrs, content \\ []) do
    wrapped_content = List.wrap(content)
    attrs = handle_units_of_measurement(attrs, [:x1, :y1, :x2, :y2])
    {"line", attrs, wrapped_content}
  end

  def escaped_iodata(iodata), do: {:escaped_iodata, iodata}

  def to_binary(element) do
    to_string(to_iodata(element))
  end

  def to_iodata({:escaped_iodata, iodata}), do: iodata

  def to_iodata({tag, attrs, []}) do
    ["<", tag, attrs_to_iodata(attrs), "/>"]
  end

  def to_iodata({tag, attrs, contents}) when is_list(contents) do
    escaped_contents = Enum.map(contents, &to_iodata/1)

    iodata_contents =
      for fragment <- escaped_contents do
        case fragment do
          {:escaped_iodata, iodata} -> iodata
          other -> other
        end
      end

    ["<", tag, attrs_to_iodata(attrs), ">", iodata_contents, "</", tag, ">"]
  end

  def to_iodata(list_of_stuff) when is_list(list_of_stuff) do
    Enum.map(list_of_stuff, &to_iodata/1)
  end

  # TODO: centralize all XML escaping of text here
  def to_iodata(text) when is_binary(text), do: xml_escape_to_iodata(text)

  def attrs_to_iodata([]), do: []

  def attrs_to_iodata(attrs) do
    for {key, value} <- attrs, value != nil do
      escaped_value =
        if key == :style or key == "style" do
          {:escaped_iodata, iodata} = xml_escape_iodata(style_to_iodata(value))
          iodata
        else
          attr_value_to_iodata(value)
        end

      [" ", to_string(key), "=\"", escaped_value, "\""]
    end
  end

  def style_to_iodata(style_attrs) do
    for {key, value} <- style_attrs do
      [to_string(key), ":", to_string(value), ";"]
    end
  end

  def attr_value_to_iodata(%RGB{} = color) do
    # Handle all cases for alpha
    alpha =
      case color.alpha do
        i when is_integer(i) -> i / 256
        f when is_float(f) -> f
      end

    "rgba(#{color.red}, #{color.green}, #{color.blue}, #{alpha})"
  end

  def attr_value_to_iodata(number) when is_float(number) do
    display_rounded_float(number)
  end

  def attr_value_to_iodata(attr_value) do
    {:escaped_iodata, iodata} = xml_escape_iodata(to_string(attr_value))
    iodata
  end

  # --------------------------------------------------------------------
  # Copied from Plug.HTML
  # (https://github.com/elixir-plug/plug/blob/v1.15.3/lib/plug/xml.ex)
  # --------------------------------------------------------------------
  # Copyright (c) 2013 Plataformatec.
  # Licensed under the Apache License, Version 2.0;
  # --------------------------------------------------------------------
  # TODO: see if there are any legal issues with the Apache License here

  @spec xml_escape_iodata(iodata) :: {:escaped_iodata, iodata}
  def xml_escape_iodata(data) when is_list(data) do
    {:escaped_iodata, Enum.map(data, &xml_escape/1)}
  end

  def xml_escape_iodata(data) when is_binary(data) do
    {:escaped_iodata, xml_escape(data)}
  end

  @spec xml_escape(any) :: any
  def xml_escape(data) when is_binary(data) do
    IO.iodata_to_binary(to_iodata(data, 0, data, []))
  end

  @doc ~S"""
  Escapes the given HTML to iodata.

      iex> Quartz.SVG.xml_escape_to_iodata("foo")
      {:escaped_iodata, "foo"}

      iex> Quartz.SVG.xml_escape_to_iodata("<foo>")
      {:escaped_iodata, [[[] | "&lt;"], "foo" | "&gt;"]}

      iex> Quartz.SVG.xml_escape_to_iodata("quotes: \" & \'")
      {:escaped_iodata, [[[[], "quotes: " | "&quot;"], " " | "&amp;"], " " | "&#39;"]}

  """
  @spec xml_escape_to_iodata(String.t()) :: {:escaped_iodata, iodata}
  def xml_escape_to_iodata(data) when is_binary(data) do
    {:escaped_iodata, to_iodata(data, 0, data, [])}
  end

  escapes = [
    {?<, "&lt;"},
    {?>, "&gt;"},
    {?&, "&amp;"},
    {?", "&quot;"},
    {?', "&#39;"}
  ]

  for {match, insert} <- escapes do
    defp to_iodata(<<unquote(match), rest::bits>>, skip, original, acc) do
      to_iodata(rest, skip + 1, original, [acc | unquote(insert)])
    end
  end

  defp to_iodata(<<_char, rest::bits>>, skip, original, acc) do
    to_iodata(rest, skip, original, acc, 1)
  end

  defp to_iodata(<<>>, _skip, _original, acc) do
    acc
  end

  for {match, insert} <- escapes do
    defp to_iodata(<<unquote(match), rest::bits>>, skip, original, acc, len) do
      part = binary_part(original, skip, len)
      to_iodata(rest, skip + len + 1, original, [acc, part | unquote(insert)])
    end
  end

  defp to_iodata(<<_char, rest::bits>>, skip, original, acc, len) do
    to_iodata(rest, skip, original, acc, len + 1)
  end

  defp to_iodata(<<>>, 0, original, _acc, _len) do
    original
  end

  defp to_iodata(<<>>, skip, original, acc, len) do
    [acc | binary_part(original, skip, len)]
  end
end
