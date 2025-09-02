defmodule SkepticBot.YtDlp.EpisodeProcessor do
  @moduledoc """
  Processes all yt-dlp episodes and downloads them
  """

  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.DownloadingWorker

  require Logger

  @candace_channel "https://www.youtube.com/@RealCandaceO/streams"
  @eddie_rokfin_channel "https://rokfin.com/eddiebravo"
  @eddie_rumble_channel "https://rumble.com/c/eddiebravo/videos?e9s=src_v1_sa%2Csrc_v1_sa_o"

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

  defp get_video_length(duration, @candace_channel) do
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

  defp get_external_id(webpage_url, @candace_channel) do
    <<"https://www.youtube.com/watch?", webpage_id::binary>> = webpage_url

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
