defmodule Quartz.MixProject do
  use Mix.Project

  @version "0.6.0"

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
        "compile.download_fonts": &download_fonts/1
      ],
      name: "Quartz",
      description: "Plotting library for Elixir",
      source_url: "https://github.com/tmbb/quartz",
      docs: [
        assets: %{"assets" => "assets"}
      ]
    ]
  end

  defp download_fonts(_) do
    Quartz.FontDownloader.maybe_download_fonts()
  end

  defp package() do
    [
      files: ~w(
        lib
        priv/demo
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

  defp elixirc_paths(:test), do: ["lib/", "demo/lib/", "test/support"]
  defp elixirc_paths(:dev), do: ["lib/", "demo/lib/"]
  defp elixirc_paths(_env), do: ["lib/"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dantzig, "~> 0.2"},
      {:resvg, "~> 0.4"},
      {:decimal, "> 0.0.0"},
      {:conrex, "~> 1.0.0"},
      {:explorer, "~> 0.8"},
      {:floki, "~> 0.36", runtime: false},
      {:benchee, "~> 1.3", only: [:dev, :test]},
      {:rustler_precompiled, "~> 0.8"},
      {:statistics, "~> 0.6", only: [:dev, :test], runtime: false},
      {:approval, "~> 0.2", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev}
    ]
  end
end
