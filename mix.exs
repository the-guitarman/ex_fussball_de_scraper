defmodule ExFussballDeScraper.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_fussball_de_scraper,
      version: "0.1.1",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env == :prod,
      docs: [extras: ["README.md"]],
      description: "Provides information from a team website at fussball.de.",
      package: package(),
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
      {:ex_doc, "~> 0.18.0", only: :dev}
    ]
  end

  def package do
    [
      name: :ex_fussball_de_scraper,
      files: ["lib", "mix.exs"],
      maintainers: ["guitarman78"],
      licenses: ["LGPL 3.0"],
      links: %{"Github" => "https://github.com/the-guitarman/ex_fussball_de_scraper"}
    ]
  end
end
