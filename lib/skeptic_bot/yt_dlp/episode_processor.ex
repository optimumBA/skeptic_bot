defmodule SkepticBot.YtDlp.EpisodeProcessor do
  @moduledoc """
  Processes all yt-dlp episodes and downloads them
  """

  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.DownloadingWorker
  alias SkepticBot.Podcasts.Podcast

  require Logger

  @broken_simulation_channel "https://www.youtube.com/@SamTripoli/videos"
  @candace_channel "https://www.youtube.com/@RealCandaceO/streams"
  @deepwaters_channel "https://www.youtube.com/@deepwaterscsc/videos"
  @eddie_rokfin_channel "https://rokfin.com/eddiebravo"
  @eddie_rumble_channel "https://rumble.com/c/eddiebravo/videos?e9s=src_v1_sa%2Csrc_v1_sa_o"
  @nephilim_death_squad_channel "https://www.youtube.com/@NephilimDeathSquad/streams"
  @yt_channels [
    @broken_simulation_channel,
    @candace_channel,
    @deepwaters_channel,
    @nephilim_death_squad_channel
  ]

  @type channel :: String.t()
  @type duration :: String.t()
  @type episode :: {title(), duration(), thumbnail(), webpage_url()}
  @type job :: Oban.Job.t()
  @type podcast :: Podcast.t()
  @type thumbnail :: String.t()
  @type title :: String.t()
  @type webpage_url :: String.t()

  @spec maybe_download_episode(episode(), channel(), podcast()) ::
          {:ok, job()} | {:error, Ecto.Changeset.t()} | nil
  def maybe_download_episode({title, duration, thumbnail, webpage_url}, channel, podcast) do
    external_id = get_external_id(webpage_url, channel)

    unless Podcasts.episode_exists?(external_id) do
      {:ok, %Podcasts.Episode{} = episode} =
        Podcasts.create_episode(%{
          "episode_length" => get_video_length(duration, channel),
          "external_id" => external_id,
          "podcast_id" => podcast.id,
          "thumbnail" => thumbnail,
          "title" => title
        })

      DownloadingWorker.enqueue(%{
        "id" => episode.id,
        "podcast" => podcast.name,
        "video_url" => webpage_url
      })
    end
  end

  defp get_video_length(duration, channel)
       when channel in @yt_channels do
    String.to_integer(duration)
  end

  defp get_video_length(duration, @eddie_rokfin_channel) do
    duration
    |> String.to_float()
    |> round()
  end

  defp get_video_length(duration, @eddie_rumble_channel) do
    String.to_integer(duration)
  end

  defp get_external_id(webpage_url, channel)
       when channel in @yt_channels do
    <<"https://www.youtube.com/watch?v=", webpage_id::binary>> = webpage_url

    webpage_id
  end

  defp get_external_id(webpage_url, @eddie_rokfin_channel) do
    <<"https://rokfin.com/post/", webpage_id::binary>> = webpage_url

    webpage_id
  end

  defp get_external_id(webpage_url, @eddie_rumble_channel) do
    <<"https://rumble.com/", webpage_id::binary>> = webpage_url

    webpage_id
  end
end
