defmodule ThumbnailsUpdater do
  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.TinfoilScraper

  require Logger

  def update() do
    Logger.debug("Thumbnail update is starting", ansi_color: :green)
    update_thumbnails_from_page(0)
    Logger.debug("Thumbnail update is Finished", ansi_color: :green)
  end

  defp update_thumbnails_from_page(start) do
    url = String.replace(TinfoilScraper.get_url(), "<start>", Integer.to_string(start))

    case Req.get(url) do
      {:ok, %Req.Response{status: 200, body: %{"data" => []}}} ->
        :ok

      {:ok, %Req.Response{status: 200, body: body}} ->
        # Process each episode in the current page
        Enum.each(body["data"], fn podcast_episode ->
          podcast_episode["uuid"]
          |> Podcasts.get_episode_by_external_id()
          |> maybe_update_episode(podcast_episode["thumbnailPath"])
        end)

        update_thumbnails_from_page(start + 100)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp maybe_update_episode(nil, _thumbnail_path) do
    :ok
  end

  defp maybe_update_episode(episode, thumbnail_path) do
    Podcasts.update_episode(episode, %{thumbnail: thumbnail_path})
  end
end

{:ok, _} = Application.ensure_all_started(:skeptic_bot)
ThumbnailsUpdater.update()
