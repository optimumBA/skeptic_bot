defmodule UpdateSamEpisodesWithThumbnail do
  import Ecto.Query

  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.Episode
  alias SkepticBot.Podcasts.ThumbnailDownloader
  alias SkepticBot.Repo

  require Logger

  def start do
    Logger.debug("Downloading and uploading Sam's episodes with no thumbnails",
      ansi_color: :green
    )

    ids = ThumbnailDownloader.return_sam_podcast_ids()

    transformation = fn ->
      Episode
      |> where([e], e.podcast_id in ^ids)
      |> Repo.stream(max_rows: 100)
      |> Stream.each(&download_and_store(&1, &1.thumbnail))
      |> Stream.run()
    end

    Repo.transaction(transformation, timeout: :infinity)

    Logger.debug("Finished downloading and uploading Sam's episodes with no thumbnails",
      ansi_color: :green
    )
  end

  defp download_and_store(episode, <<"/static/thumbnails/", _remainder_thumbnail::binary>>) do
    podcast = Podcasts.get_podcast(episode.podcast_id)
    ThumbnailDownloader.store_thumbnail(episode, podcast.name)
  end

  defp download_and_store(_episode, _thumbnail), do: :ok
end

UpdateSamEpisodesWithThumbnail.start()
