defmodule SitemapXml.SitemapUrlTree do
  @moduledoc """
  A module to fetch and parse sitemap XML concurrently and return a nested data structure.
  """

  alias HTTPoison
  import SweetXml

  @max_concurrency 40

  @doc """
  Fetches and parses the sitemap from the provided URL and returns a nested structure.

  ## Examples

      iex> SitemapXml.SitemapUrlTree.fetch_url_tree("https://web.site/sitemap.xml")
      {:ok, [%{"sitemap.xml" => [%{url: "https://web.site/page1", lastmod: ..., priority: ...}, ...]}]}
  """
  def fetch_url_tree(url) do
    with {:ok, body} <- fetch_sitemap(url),
         {:ok, urls} <- parse_sitemap(url, body) do
      {:ok, urls}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Fetches the raw sitemap XML from the given URL.

  ## Examples

      iex> SitemapXml.SitemapUrlTree.fetch_sitemap("https://web.site/sitemap.xml")
      {:ok, "<?xml version=\"1.0\" encoding=\"UTF-8\"?><?xml-styleshee..."}

      iex> SitemapXml.SitemapUrlTree.fetch_sitemap("https://web.site/404.xml")
      {:error, "HTTP error with status 404"}
  """
  def fetch_sitemap(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: status}} ->
        {:error, "HTTP error with status #{status}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @doc """
  Parses the sitemap XML to extract URLs with their attributes, or processes nested sitemaps.

  ## Examples

      iex> SitemapXml.SitemapUrlTree.parse_sitemap("https://web.site/sitemap.xml", "<urlset>...</urlset>")
      {:ok, [%{"sitemap.xml" => [%{url: "https://web.site/page1", lastmod: ..., priority: ...}, ...]}]}

      iex> SitemapXml.SitemapUrlTree.parse_sitemap("https://web.site/nested_sitemap.xml", "<sitemapindex>...</sitemapindex>")
      ...
  """
  def parse_sitemap(url, body) do
    case SweetXml.xpath(body, ~x"//urlset/url"l) do
      [] -> process_sitemap_index(url, body)
      urls -> {:ok, [%{Path.basename(url) => extract_url_info(urls)}]}
    end
  end

  defp extract_url_info(urls) do
    Enum.map(urls, fn url ->
      %{
        url: SweetXml.xpath(url, ~x"./loc/text()"s),
        lastmod: SweetXml.xpath(url, ~x"./lastmod/text()"s),
        priority: SweetXml.xpath(url, ~x"./priority/text()"s)
      }
    end)
  end


  defp process_sitemap_index(url, body) do
    case SweetXml.xpath(body, ~x"//sitemapindex/sitemap/loc/text()"l) do
      [] ->
        {:error, "No URLs or nested sitemaps found in the sitemap"}

      sitemap_urls ->
          sitemap_urls
          |> Task.async_stream(&fetch_url_tree/1,
            max_concurrency: @max_concurrency,
            timeout: :timer.minutes(5)
          )
          |> Enum.flat_map(&unwrap_result/1)
          |> case do
            [] -> {:error, "No valid URLs found in nested sitemaps"}
            urls -> {:ok, [%{Path.basename(url) => urls}]}
          end
    end
  end

  defp unwrap_result({:ok, {:ok, urls}}), do: urls
  defp unwrap_result(_), do: []
end
