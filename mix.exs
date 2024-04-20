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
      # {:resvg, "~> 0.3"},
      {:resvg, path: "../resvg_nif"},
      {:decimal, "> 0.0.0"},
      {:conrex, "~> 1.0.0"},
      {:benchee, "~> 1.3"},
      {:explorer, "~> 0.8"},
      {:rustler, "~> 0.31", override: true},
      {:rustler_precompiled, "~> 0.7", override: true}
    ]
  end
end
