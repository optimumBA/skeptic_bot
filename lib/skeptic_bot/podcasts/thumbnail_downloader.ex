defmodule SkepticBot.Podcasts.ThumbnailDownloader do
  @moduledoc false

  alias SkepticBot.Podcasts.ReqDownloader

  @type path :: String.t()
  @type reason :: String.t()
  @type url :: String.t()

  @callback download(url(), path()) :: {:ok, path()} | {:error, reason()}

  @spec download(url(), path()) :: {:ok, path()} | {:error, reason()}
  def download(url, path), do: impl().download(url, path)

  defp impl(), do: Application.get_env(:skeptic_bot, :downloader, ReqDownloader)
end
