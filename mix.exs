defmodule Quartz.MixProject do
  use Mix.Project

  def project do
    [
      app: :quartz,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dantzig, path: "../dantzig"},
      {:decimal, "> 0.0.0"},
      {:ex_typst, "~> 0.1"},
      {:conrex, "~> 1.0.0"},
      {:benchee, "~> 1.3"},
      {:explorer, "~> 0.8"},
      {:rustler, "~> 0.31", override: true},
      {:incendium, "~> 0.4", only: [:dev, :test]}
    ]
  end
end
