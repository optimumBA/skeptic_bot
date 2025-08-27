defmodule SkepticBot.LookIntoIt.ChannelClient do
  @moduledoc false

  alias SkepticBot.LookIntoIt.YtDlpChannelClient

  @type channel :: String.t()
  @type reason :: String.t()
  @type result :: String.t()

  @callback get_channel_data(channel()) :: {:ok, result()} | {:error, reason()}

  @spec get_channel_data(channel()) :: {:ok, result()} | {:error, reason()}
  def get_channel_data(channel), do: impl().get_channel_data(channel)

  defp impl, do: Application.get_env(:skeptic_bot, :channel_client, YtDlpChannelClient)
end
