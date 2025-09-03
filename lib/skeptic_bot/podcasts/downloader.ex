defmodule SkepticBot.Podcasts.Downloader do
  @moduledoc false

  alias SkepticBot.Podcasts.ReqDownloader
  alias SkepticBot.Podcasts.YtDlpDownloader

  @type downloader_type :: atom()
  @type path :: String.t()
  @type reason :: String.t()
  @type url :: String.t()

  @callback download(url(), path()) :: {:ok, path()} | {:error, reason()}

  @spec download(url(), path(), downloader_type()) :: {:ok, path()} | {:error, reason()}
  def download(url, path, downloader_type), do: impl(downloader_type).download(url, path)

  defp impl(:req), do: Application.get_env(:skeptic_bot, :downloader, ReqDownloader)
  defp impl(:yt_dlp), do: Application.get_env(:skeptic_bot, :downloader, YtDlpDownloader)
end
