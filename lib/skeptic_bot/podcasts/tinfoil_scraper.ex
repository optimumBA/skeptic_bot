defmodule SkepticBot.Podcasts.TinfoilScraper do
  @moduledoc false

  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.DownloadingWorker

  @type episode_id :: String.t()
  @type start :: integer()

  @url "https://vid.samtripoli.com/api/v1/video-channels/tinfoilhat/videos?start=<start>&count=100&sort=-publishedAt&skipCount=false&nsfw=both"

  @spec get_url() :: String.t()
  def get_url, do: @url

  @spec scrape(start()) :: :ok | {:error, any()}
  def scrape(start \\ 0)

  def scrape(start) do
    url = String.replace(@url, "<start>", Integer.to_string(start))

    case Req.get(url) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        Enum.each(body["data"], fn episode ->
          maybe_download_episode(episode)
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

  @spec scrape_episode(episode_id(), start()) :: :ok | {:error, any()}
  def scrape_episode(uuid, start \\ 0) do
    url = String.replace(@url, "<start>", Integer.to_string(start))

    case Req.get(url) do
      {:ok, %Req.Response{status: 200, body: %{"data" => []}}} ->
        {:error, :episode_not_found}

      {:ok, %Req.Response{status: 200, body: body}} ->
        episode = Enum.find(body["data"], fn episode -> episode["uuid"] == uuid end)

        case episode do
          nil ->
            scrape_episode(uuid, start + 100)

          episode ->
            maybe_download_episode(episode)
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp maybe_download_episode(episode) do
    unless Podcasts.episode_exists?(episode["uuid"]) do
      {:ok, %Podcasts.Episode{} = episode} =
        Podcasts.create_episode(%{
          "description" => episode["description"],
          "external_id" => episode["uuid"],
          "thumbnail" => episode["thumbnailPath"],
          "title" => episode["name"]
        })

      DownloadingWorker.enqueue(%{
        "id" => episode.id,
        "external_id" => episode.external_id
      })
    end
  end
end
