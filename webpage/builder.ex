defmodule Quartz.Webpage.Builder do
  # Build the plots used for demo purposes

  @assets_dir "webpage/_target/assets"
  @output_dir "webpage/_target"

  # Use Phoenix HTML utilities
  use Phoenix.Component
  import Phoenix.HTML

  alias Quartz.Webpage.Artifacts

  use NimblePublisher,
    build: Quartz.Webpage.Page,
    from: "webpage/pages/*.md",
    as: :pages,
    highlighters: [:makeup_elixir],
    html_converter: Quartz.Webpage.Page

  # Get the pages from the magic module attribute that
  # nimble_parsec has created for us
  def all_pages() do
    Enum.sort_by(@pages, fn page -> page.path end)
  end

  def all_examples() do
    Enum.filter(all_pages(), fn page -> page.category == "example" end)
  end

  def page(assigns) do
    ~H"""
    <.layout>
      <%= raw @page.body %>
    </.layout>
    """
  end

  def layout(assigns) do
    ~H"""
    <html>
      <head>
        <link
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous"/>
        <link href="assets/css/highlight.css" rel="stylesheet"/>
      </head>
      <body>
        <nav class="navbar navbar-expand-md bg-dark mb-3" data-bs-theme="dark">
          <div class="container">
            <div class="navbar navbar-collapse">
                  <a class="navbar-brand" href="./index.html">Quartz</a>
              <ul class="navbar-nav me-auto">
                <li class="nav-item">
                </li>
                <li class="nav-item">
                  <a class="nav-link" href="https://hex.pm/packages/quartz">Hex</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" href="https://hexdocs.pm/quartz">API Docs</a>
                </li>
              </ul>
            </div>
          </div>
        </nav>
        <main class="container">
          <div class="row">
            <div class="col-md-8">
              <%= render_slot(@inner_block) %>
            </div>
          </div>
        </main>
        <script src="assets/js/matching_groups_highlighter.js"></script>
      </body>
    </html>
    """
  end

  def build(opts) do
    cached_artifacts = Keyword.get(opts, :cached_artifacts, false)

    unless cached_artifacts do
      Artifacts.run(@assets_dir)
    end

    pages = all_pages()

    for page <- pages do
      dir = Path.dirname(page.path)
      if dir != "." do
        File.mkdir_p!(Path.join([@output_dir, dir]))
      end
      render_file(page.path, page(%{page: page}))
    end

    :ok
  end

  def render_file(path, rendered) do
    safe = Phoenix.HTML.Safe.to_iodata(rendered)
    output = Path.join([@output_dir, path])
    File.write!(output, safe)
  end
end
