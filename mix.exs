defmodule JSONPath.MixProject do
  use Mix.Project

  @source_url "https://github.com/IgnacioGoldchluk/json_path"
  @version "0.1.2"

  def project do
    [
      app: :json_path,
      version: @version,
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # Docs
      name: "JSONPath",
      source_url: @source_url,
      homepage_url: @source_url,
      docs: docs(),
      package: package(),
      description: description()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp docs do
    [
      main: "JSONPath",
      extras: ["README.md", "CHANGELOG.md"]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.34", only: :dev, runtime: false, warn_if_outdated: true},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    "An RFC-9535 compliant JSONPath evaluator in pure Elixir"
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["Ignacio Goldchluk"],
      source_ref: "v#{@version}",
      links: %{"GitHub" => @source_url}
    ]
  end
end
