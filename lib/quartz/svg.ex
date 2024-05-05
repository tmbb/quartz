defmodule Quartz.SVG do
  alias Quartz.Color.RGB

  @type t :: {binary(), list(), list()}

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

  def g(attrs, contents) do
    {"g", attrs, contents}
  end

  def text(attrs, content) do
    attrs = handle_units_of_measurement(attrs, [:x, :y, :width, :height])
    contents = List.wrap(content)
    escaped_contents = for fragment <- contents do
      case fragment do
        binary when is_binary(fragment) ->
          xml_escape_to_iodata(fragment)

        other ->
          other
      end
    end

    {"text", attrs, escaped_contents}
  end

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
    # That way, all unitless values inside
    {width, attrs} = Keyword.pop(attrs, :width)
    {height, attrs} = Keyword.pop(attrs, :height)

    first_attrs = [
      {"xmlns", "http://www.w3.org/2000/svg"},
      width: "#{width}pt",
      height: "#{height}pt",
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

  def points_to_iodata(points), do: Enum.map(points, &point_to_iodata/1)

  # Move to point without drawing a line
  def point_to_iodata({:M, {x, y}}), do: ["M ", to_string(x), " ", to_string(y)]
  def point_to_iodata({:m, {dx, dy}}), do: ["m ", to_string(dx), " ", to_string(dy)]
  # Draw a line from the last point to the current point
  def point_to_iodata({:L, {x, y}}), do: ["L ", to_string(x), " ", to_string(y)]
  def point_to_iodata({:l, {dx, dy}}), do: ["l ", to_string(dx), " ", to_string(dy)]
  # Horizontal line
  def point_to_iodata({:H, x}), do: ["H ", to_string(x)]
  def point_to_iodata({:h, dx}), do: ["h ", to_string(dx)]
  # Vertical line
  def point_to_iodata({:V, y}), do: ["V ", to_string(y)]
  def point_to_iodata({:v, dy}), do: ["v ", to_string(dy)]
  # Bezier curves
  def point_to_iodata({:C, {x1, y1, x2, y2, x, y}}), do: [
    "C ", to_string(x1), to_string(y1), ", ",
          to_string(x2), to_string(y2), ", ",
          to_string(x), to_string(y)
    ]

  def point_to_iodata({:c, {dx1, dy1, dx2, dy2, dx, dy}}), do: [
    "c ", to_string(dx1), to_string(dy1), ", ",
          to_string(dx2), to_string(dy2), ", ",
          to_string(dx), to_string(dy)
    ]

  def point_to_iodata(z) when z in [:z, :Z] do
    "z"
  end

  def rect(attrs, content \\ []) do
    wrapped_content = List.wrap(content)
    attrs = handle_units_of_measurement(attrs, [:x, :y, :width, :height])
    {"rect", attrs, wrapped_content}
  end

  def circle(attrs, content \\ []) do
    wrapped_content = List.wrap(content)
    attrs = handle_units_of_measurement(attrs, [:cx, :cy, :r])
    {"circle", attrs, wrapped_content}
  end

  def line(attrs, content \\ []) do
    wrapped_content = List.wrap(content)
    attrs = handle_units_of_measurement(attrs, [:x1, :y1, :x2, :y2])
    {"line", attrs, wrapped_content}
  end

  def desc(attrs, content \\ []) do
    wrapped_content = List.wrap(content)
    {"desc", attrs, wrapped_content}
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

    iodata_contents = for fragment <- escaped_contents do
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
    alpha = case color.alpha do
      i when is_integer(i) -> (i / 256)
      f when is_float(f) -> f
    end

    "rgba(#{color.red}, #{color.green}, #{color.blue}, #{alpha})"
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
