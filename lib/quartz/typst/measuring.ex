defmodule Quartz.Typst.Measuring do
  alias Quartz.Typst.TypstAst
  alias Quartz.Typst.Serializer
  alias Quartz.Length

  def measure([]), do: %{}

  def measure(elements) do
    items = Enum.map(elements, fn element -> {element.id, element} end)
    dictionary = TypstAst.dictionary(items)
    serialized_dictionary = Serializer.serialize(dictionary)

    # Insert the serialized plot into a template
    typst_file = """
    #let elements = #{serialized_dictionary}

    #style(styles => {
      let sizes = ();
      for (id, element) in elements {
        let size = measure(element, styles)
        let line = (
          id,
          ":",
          repr(size.width),
          ":",
          repr(size.height)
        ).join()

        sizes.push(line)
      }

      assert(0 == 1, message: sizes.join("\\n"))

      [Unreachable]
    })
    """

    # Try to render the typst code into PDF
    # Typst will return an error
    {:error, output} = ExTypst.render_to_pdf(typst_file)
    [_ignore, data] = String.split(output, "assertion failed: ")

    sizes =
      data
      |> String.split("\n")
      |> Enum.map(fn line ->
        [id, width, height] = String.split(line, ":")
        {id, {parse_length(width), parse_length(height)}}
      end)
      |> Enum.into(%{})

    measurements =
      Enum.map(elements, fn element ->
        {width, height} = Map.fetch!(sizes, to_string(element.id))
        {element.id, %{element | width: width, height: height}}
      end)

    Enum.into(measurements, %{})
  end

  defp parse_length(text) do
    {float, ""} =
      text
      |> String.trim("pt")
      |> Float.parse()

    Length.pt(float)
  end
end
