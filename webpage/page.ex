defmodule Quartz.Webpage.Page do
  defstruct [
    :id,
    :author,
    :title,
    :body,
    :description,
    :tags,
    :date,
    :category,
    :path
  ]

  def build(filename, attrs, body) do
    page = struct(__MODULE__, attrs)

    path =
      filename
      |> Path.rootname()
      |> Path.relative_to("webpage/pages")
      |> Kernel.<>(".html")

      %{page | body: body, path: path}
  end

  def image_card(opts) do
    image = Keyword.fetch!(opts, :image)
    title = Keyword.fetch!(opts, :title)
    text = Keyword.fetch!(opts, :text)
    image_width = Keyword.get(opts, :image_width, 302)
    card_width = Keyword.get(opts, :card_width, image_width + 48)

    """
    <div class="card shadow mb-4 me-4" style="display: inline-block; width: #{card_width};">
    <div class="card-body">
    <img width="#{302}" alt="#{title}" src="#{image}"/>
    <h5 class="card-title">#{title}</h5>
    <p class="card-text">#{text}</p>
    </div>
    </div>
    """
  end

  def convert(filepath, body, _attrs, opts) do
    if Path.extname(filepath) in [".md", ".markdown"] do
      highlighters = Keyword.get(opts, :highlighters, [])

      body
      |> EEx.eval_string(assigns: [image_card: &image_card/1])
      |> Earmark.as_html!()
      |> NimblePublisher.highlight(highlighters)
    end
  end
end
