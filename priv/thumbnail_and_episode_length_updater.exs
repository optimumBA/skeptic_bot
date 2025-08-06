defmodule ThumbnailAndEpisodeLengthUpdater do
  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.TinfoilScraper
  alias SkepticBot.LookIntoIt.ChannelClient

  require Logger

  def update() do
    Logger.debug("Update is starting", ansi_color: :green)
    update_thumbnails_and_episode_lengths(0)
    Logger.debug("Update is completed", ansi_color: :green)
  end

  defp update_thumbnails_and_episode_lengths(start) do
    {:ok, result} = ChannelClient.get_channel_data()

    url = String.replace(TinfoilScraper.get_url(), "<start>", Integer.to_string(start))

    case Req.get(url) do
      {:ok, %Req.Response{status: 200, body: %{"data" => []}}} ->
        :ok

      {:ok, %Req.Response{status: 200, body: body}} ->
        Enum.each(body["data"], fn podcast_episode ->
          podcast_episode["uuid"]
          |> Podcasts.get_episode_by_external_id()
          |> maybe_update_episode(podcast_episode["thumbnailPath"], podcast_episode["duration"])
        end)

        update_thumbnails_and_episode_lengths(start + 100)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp maybe_update_episode(nil, _thumbnail_path, _podcast_length) do
    :ok
  end

  defp maybe_update_episode(episode, thumbnail_path, podcast_length) do
    Podcasts.update_episode(episode, %{thumbnail: thumbnail_path, episode_length: podcast_length})
  end
end

ThumbnailAndEpisodeLengthUpdater.update()
