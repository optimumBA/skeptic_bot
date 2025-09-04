defmodule StoreThumbnailsOnTigris do
  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.Episode
  alias SkepticBot.Podcasts.ThumbnailDownloader
  alias SkepticBot.Repo

  require Logger

  def start do
    Logger.debug("Downloading and uploading thumbnails is starting", ansi_color: :green)

    Episode
    |> Repo.all()
    |> Enum.each(&download_and_store/1)

    Logger.debug("Finished downloading and uploading thumbnails", ansi_color: :green)
  end

  defp download_and_store(episode) do
    podcast = Podcasts.get_podcast(episode.podcast_id)
    ThumbnailDownloader.store_thumbnail(episode.id, podcast.name)
  end
end

StoreThumbnailsOnTigris.start()
