defmodule Quartz.MixProject do
  use Mix.Project

  @version "0.8.1"

  def project do
    [
      app: :quartz,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers() ++ [:download_fonts],
      package: package(),
      aliases: [
        webpage: [
          "compile",
          &build_webpage/1
        ],
        "compile.download_fonts": &download_fonts/1
      ],
      name: "Quartz",
      description: "Plotting library for Elixir",
      source_url: "https://github.com/tmbb/quartz"
    ]
  end

  defp download_fonts(_) do
    Quartz.FontDownloader.maybe_download_fonts()
  end

  defp build_webpage(args) do
    if Mix.env() in [:dev, :test] do
      cached_artifacts =
        case args do
          ["--cached-artifacts"] ->
            true

          [] ->
            false
        end

      Quartz.Webpage.Builder.build(
        cached_artifacts: cached_artifacts
      )

      :ok
    else
      :ok
    end
  end

  defp package() do
    [
      files: ~w(
        lib
        priv/typst-symbols.html
        priv/UnicodeData.txt
        priv/font_hashes.exs
        .formatter.exs
        mix.exs
        README*
        LICENSE*
        CHANGELOG*
      ),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/tmbb/quartz"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib/", "webpage/", "test/support"]
  defp elixirc_paths(:dev), do: ["lib/", "webpage/"]
  defp elixirc_paths(_env), do: ["lib/"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dantzig, "~> 0.2"},
      {:resvg, "~> 0.4"},
      {:decimal, "> 0.0.0"},
      {:conrex, "~> 1.0.0"},
      {:explorer, "~> 0.10"},
      {:floki, "~> 0.36", runtime: false},
      {:benchee, "~> 1.3", only: [:dev, :test]},
      {:rustler, "~> 0.34", runtime: false},
      {:rustler_precompiled, "~> 0.8"},
      {:statistics, "~> 0.6", only: [:dev, :test], runtime: false},
      {:approval, "~> 0.2", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev},
      {:nimble_publisher, "~> 1.1", only: [:dev, :test]},
      {:makeup_elixir, ">= 0.0.0", only: [:dev, :test]},
      {:phoenix_live_view, "~> 1.0", only: [:dev, :test]}
    ]
  end
end
