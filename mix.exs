defmodule SitemapXml.MixProject do
  use Mix.Project

  def project do
    [
      app: :sitemap_xml,
      version: "0.1.1",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "A module to fetch and parse sitemap XML.",
      package: [
        licenses: ["MIT"],
        maintainers: ["Bishwas Bhandari"],
        links: %{
          "GitHub" => "https://github.com/Bishwas-py/sitemap.xml",
          "Author" => "https://bishwas.net",
          "Website" => "https://webmatrices.com"
        }
      ]
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
      {:httpoison, "~> 1.8"},
      {:sweet_xml, "~> 0.7.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
