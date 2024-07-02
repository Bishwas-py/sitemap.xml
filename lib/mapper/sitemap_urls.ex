defmodule SitemapXml.SitemapUrls do
  @moduledoc """
  A module to fetch and parse sitemap XML concurrently.
  """

  use HTTPoison.Base
  import SweetXml

  @max_concurrency 40

  @doc """
  Fetches and parses the sitemap from the provided URL.

  ## Examples

      iex> SitemapXml.SitemapUrls.fetch_urls("https://web.site/sitemap.xml")
      {:ok, ["https://web.site/page1", "https://web.site/page2", ...]}
  """
  def fetch_urls(url) do
    with {:ok, body} <- fetch_sitemap(url),
         {:ok, urls} <- parse_sitemap(body) do
      {:ok, urls}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Fetches the raw sitemap XML from the given URL.

  ## Examples

      iex> SitemapXml.SitemapUrls.fetch_sitemap("https://web.site/sitemap.xml")
      {:ok, "<urlset>...</urlset>"}

      iex> SitemapXml.SitemapUrls.fetch_sitemap("https://web.site/404.xml")
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
  Parses the sitemap XML to extract URLs or process nested sitemaps.

  ## Examples

      iex> SitemapXml.SitemapUrls.parse_sitemap("<urlset>...</urlset>")
      {:ok, ["https://web.site/page1", "https://web.site/page2"]}

      iex> SitemapXml.SitemapUrls.parse_sitemap("<sitemapindex>...</sitemapindex>")
      ...
  """
  def parse_sitemap(body) do
    case SweetXml.xpath(body, ~x"//urlset/url/loc/text()"l) do
      [] -> process_sitemap_index(body)
      urls -> {:ok, urls}
    end
  end

  # Processes a sitemap index XML to extract URLs from nested sitemaps.
  #
  # Parameters:
  #   - body: The raw XML content of the sitemap index.
  #
  # Returns:
  #   - {:ok, urls} when URLs are successfully extracted from nested sitemaps.
  #   - {:error, reason} if there is any error in processing the sitemap index.
  defp process_sitemap_index(body) do
    case SweetXml.xpath(body, ~x"//sitemapindex/sitemap/loc/text()"l) do
      [] ->
        {:error, "No URLs or nested sitemaps found in the sitemap"}

      sitemap_urls ->
          sitemap_urls
          |> Task.async_stream(&fetch_urls/1,
            max_concurrency: @max_concurrency,
            timeout: :timer.minutes(5)
          )
          |> Enum.flat_map(&unwrap_result/1)
          |> case do
            [] -> {:error, "No valid URLs found in nested sitemaps"}
            urls -> {:ok, urls}
          end
    end
  end

  # Unwraps the result of the asynchronous task.
  #
  # Extracts the list of URLs from a successful task result or returns
  # an empty list in case of an error.
  #
  # Parameters:
  #   - result: The result of the task, which can be either {:ok, {:ok, urls}} or an error tuple.
  #
  # Returns:
  #   - The list of URLs extracted from the task result, or an empty list in case of an error.

  defp unwrap_result({:ok, {:ok, urls}}), do: urls
  defp unwrap_result(_), do: []
end
