defmodule SkepticBot.YtDlp.Helpers do
  @moduledoc """
  Helper functions for scraping episodes from ytdlp
  """

  alias SkepticBot.Podcasts.Podcast
  alias SkepticBot.YtDlp.EpisodeProcessor

  require Logger

  @type channel :: String.t()
  @type podcast :: Podcast.t()

  @spec get_yesterday_date :: String.t()
  def get_yesterday_date do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.add(-5, :day)
    |> Calendar.strftime("%Y%m%d")
  end

  @spec wait_for_episodes(channel(), podcast()) :: :ok
  def wait_for_episodes(channel, podcast) do
    receive do
      {_port, {:data, msg}} ->
        Logger.info(msg)

        msg
        |> format_message()
        |> process_episode(channel, podcast)

        wait_for_episodes(channel, podcast)

      {:close_port, port} ->
        Logger.info("Closed the port")

        case Port.info(port) do
          nil ->
            :ok

          _port_info ->
            Port.close(port)
            :ok
        end
    end
  end

  defp process_episode(episode, channel, podcast) do
    EpisodeProcessor.maybe_download_episode(episode, channel, podcast)
    :ok
  end

  defp format_message(msg) do
    msg
    |> String.trim("\n")
    |> String.split("~~")
    |> List.to_tuple()
  end
end
