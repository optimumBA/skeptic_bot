defmodule SkepticBot.Downloader do
  @moduledoc false

  alias SkepticBot.ReqDownloader

  @type audio_url :: String.t()
  @type external_id :: String.t()
  @type id :: String.t()
  @type reason :: String.t()
  @type url :: String.t()

  @callback process_with_flame(id(), url(), external_id()) ::
              {:ok, audio_url()} | {:error, reason()}

  @spec process_with_flame(id(), url(), external_id()) ::
          {:ok, audio_url()} | {:error, reason()}
  def process_with_flame(id, url, external_id),
    do: impl().process_with_flame(id, url, external_id)

  defp impl, do: Application.get_env(:skeptic_bot, :downloader, ReqDownloader)
end
