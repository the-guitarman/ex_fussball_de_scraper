defmodule ExFussballDeScraper.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_fussball_de_scraper,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      application: [:timex],
      extra_applications: [:logger],
      mod: {ExFussballDeScraper.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 0.8"},
      {:timex, "~> 3.3"},
      {:floki, "~> 0.20"},
    ]
  end
end
