defmodule SkepticBot.Podcasts.TinfoilScraper do
  @url "https://vid.samtripoli.com/api/v1/video-channels/tinfoilhat/videos?start=<start>&count=100&sort=-publishedAt&skipCount=false&nsfw=both"

  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.DownloadingWorker

  def scrape(start \\ 0)

  def scrape(start) do
    url = String.replace(@url, "<start>", Integer.to_string(start))

    case Req.get(url) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        Enum.each(body["data"], fn episode ->
          unless Podcasts.episode_exists?(episode["uuid"]) do
            {:ok, %Podcasts.Episode{} = episode} =
              Podcasts.create_episode(%{
                "description" => episode["description"],
                "external_id" => episode["uuid"],
                "title" => episode["name"]
              })

            DownloadingWorker.enqueue(%{
              "id" => episode.id,
              "external_id" => episode.external_id
            })
          end
        end)

        if Enum.empty?(body["data"]) do
          :ok
        else
          scrape(start + 100)
        end

      {:error, reason} ->
        {:error, reason}
    end
  end
end
