defmodule SitemapXml do
  @moduledoc """
  A module to fetch and parse sitemap XML.
  """

  defmacro __using__(_) do
    quote do
      alias SitemapXml.SitemapUrls
      alias SitemapXml.SitemapUrlTree
    end
  end
end
