defmodule Quartz.MixProject do
  use Mix.Project

  def project do
    [
      app: :quartz,
      version: "0.1.0",
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

  defp elixirc_paths(:test), do: ["lib/", "test/support"]
  defp elixirc_paths(:dev), do: ["lib/", "demo/lib/"]
  defp elixirc_paths(_env), do: ["lib/"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dantzig, path: "../dantzig"},
      {:incendium, path: "../incendium", only: [:dev, :test]},
      {:statistics, "~> 0.6", only: [:dev, :test]},
      {:resvg, "~> 0.3"},
      {:decimal, "> 0.0.0"},
      {:conrex, "~> 1.0.0"},
      {:benchee, "~> 1.3"},
      {:explorer, "~> 0.8"},
      {:rustler, "~> 0.31", override: true},
      {:rustler_precompiled, "~> 0.7", override: true},
      {:ex_doc, "~> 0.34", only: :dev}
    ]
  end
end
