defmodule Quartz.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :quartz,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      docs: [
        assets: %{"assets" => "assets"}
      ]
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
      # {:dantzig, "~> 0.1"},
      {:dantzig, path: "../dantzig"},
      {:resvg, "~> 0.4"},
      {:decimal, "> 0.0.0"},
      {:conrex, "~> 1.0.0"},
      {:explorer, "~> 0.8"},
      {:floki, "~> 0.36", runtime: false},
      {:benchee, "~> 1.3", only: [:dev, :test]},
      {:rustler_precompiled, "~> 0.7", override: true},
      # {:incendium, path: "../incendium", only: [:dev, :test]},
      {:statistics, "~> 0.6", only: [:dev, :test]},
      # {:approval, ">= 0.0.0", only: [:dev, :test]},
      {:approval, path: "../approval", only: [:dev, :test]},
      {:ex_doc, "~> 0.34", only: :dev}
    ]
  end
end
