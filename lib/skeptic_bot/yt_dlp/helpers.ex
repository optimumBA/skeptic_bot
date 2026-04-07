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
    |> NaiveDateTime.add(-1, :day)
    |> Calendar.strftime("%Y%m%d")
  end

  @spec wait_for_episodes(channel(), podcast()) :: :ok
  def wait_for_episodes(channel, podcast), do: wait_for_episodes(channel, podcast, [])

  defp wait_for_episodes(channel, podcast, errors) do
    receive do
      {_port, {:data, msg}} ->
        case format_message(msg) do
          {_title, _duration, _thumbnail, _webpage_url} = episode ->
            process_episode(episode, channel, podcast)
            wait_for_episodes(channel, podcast, errors)

          _error ->
            wait_for_episodes(channel, podcast, [msg | errors])
        end

      {:close_port, port} ->
        Logger.info("Closed the port for channel #{channel}")

        if errors != [] do
          reason = errors |> Enum.reverse() |> Enum.join()

          Logger.error(
            "The episode for the channel: #{channel} in podcast: #{podcast.name} failed to download. Reason: #{reason}"
          )

          Appsignal.send_error(
            %RuntimeError{
              message:
                "Episode download failed for channel: #{channel} in podcast: #{podcast.name}. Reason: #{reason}"
            },
            []
          )
        end

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
