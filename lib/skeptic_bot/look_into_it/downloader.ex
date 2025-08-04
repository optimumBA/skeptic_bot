defmodule SkepticBot.LookIntoIt.Downloader do
  @moduledoc false

  alias SkepticBot.LookIntoIt.YtDlpDownloader

  @type path :: String.t()
  @type reason :: String.t()
  @type url :: String.t()

  @callback download(url(), path()) :: {:ok, path()} | {:error, reason()}

  @spec download(url(), path()) :: {:ok, path()} | {:error, reason()}
  def download(url, path), do: impl().download(url, path)

  defp impl, do: Application.get_env(:skeptic_bot, :downloader, YtDlpDownloader)
end
