# Elixir Sitemap Xml

SitemapXml is an Elixir library designed to fetch and parse sitemap XML files concurrently. It provides functionality to extract URLs from sitemaps and nested sitemaps efficiently.

## Installation

Add `sitemap_xml` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sitemap_xml, "~> 0.1.2"}
  ]
end
```

## Usage

### Fetching and Parsing Sitemaps

To fetch and parse a sitemap from a given URL, use the `SitemapXml.SitemapUrls.fetch_urls/1` function:

```elixir
iex> SitemapXml.SitemapUrls.fetch_urls("https://web.site/sitemap.xml")
{:ok, ["https://web.site/page1", "https://web.site/page2", ...]}
```

### Fetching and Parsing Nested Sitemaps

To fetch and parse a nested sitemap and return a nested data structure, use the `SitemapXml.SitemapUrlTree.fetch_url_tree/1` function:

```elixir
iex> SitemapXml.SitemapUrlTree.fetch_url_tree("https://web.site/sitemap.xml")
{:ok, [%{"sitemap.xml" => [%{url: "https://web.site/page1", lastmod: ..., priority: ...}, ...]}]}
```

## Documentation

The documentation can be found at [https://hexdocs.pm/sitemap_xml](https://hexdocs.pm/sitemap_xml).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request on GitHub.

## Maintainers

- Bishwas Bhandari ([bishwas.net](https://bishwas.net))

## Links

- [GitHub](https://github.com/Bishwas-py/sitemap.xml)
- [Author](https://bishwas.net)
- [Website](https://webmatrices.com)