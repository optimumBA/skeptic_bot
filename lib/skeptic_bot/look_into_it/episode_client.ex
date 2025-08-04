defmodule SkepticBot.LookIntoIt.EpisodeClient do
  @moduledoc false

  alias SkepticBot.LookIntoIt.YtDlpEpisodeClient

  @type reason :: String.t()
  @type result :: String.t()

  @callback get_channel_data :: {:ok, result()} | {:error, reason()}

  @spec get_channel_data :: {:ok, result()} | {:error, reason()}
  def get_channel_data, do: impl().get_channel_data()

  defp impl, do: Application.get_env(:skeptic_bot, :episode_client, YtDlpEpisodeClient)
end
