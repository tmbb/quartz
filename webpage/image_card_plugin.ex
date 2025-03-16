defmodule Quartz.Webpage.ImageCardPlugin do
  def as_html(line) do
    {opts, []} =
      line
      |> String.trim_trailing("$$")
      |> Code.string_to_quoted!()
      |> Code.eval_quoted()

    image = Keyword.fetch!(opts, :image)
    title = Keyword.fetch!(opts, :title)
    text = Keyword.fetch!(opts, :text)
    image_width = Keyword.get(opts, :image_width, 302)
    card_width = Keyword.get(opts, :card_width, image_width + 48)

    """
    <div class="card shadow mb-4 me-4" style="display: inline-block; width: #{card_width};">
    <div class="card-body">
    <img width="#{302}" src="#{image}"/>
    <h5 class="card-title">#{title}</h5>
    <p class="card-text">#{text}</p>
    </div>
    </div>
    """
  end
end
