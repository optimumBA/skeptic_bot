defmodule SkepticBot.YtDlp.ChannelClient do
  @moduledoc false

  alias SkepticBot.YtDlp.YtDlpChannelClient

  @type channel :: String.t()
  @type cookie_file :: String.t()
  @type date :: String.t()
  @type reason :: String.t()
  @type result :: String.t()

  @callback get_channel_data(channel()) :: {:ok, result()} | {:error, reason()}
  @callback get_channel_data_from_port(date(), cookie_file(), channel()) ::
              port()

  @spec get_channel_data(channel()) :: {:ok, result()} | {:error, reason()}
  def get_channel_data(channel), do: impl().get_channel_data(channel)

  @spec get_channel_data_from_port(date(), cookie_file(), channel()) ::
          port()
  def get_channel_data_from_port(date, cookie_file, channel),
    do: impl().get_channel_data_from_port(date, cookie_file, channel)

  defp impl, do: Application.get_env(:skeptic_bot, :channel_client, YtDlpChannelClient)
end
