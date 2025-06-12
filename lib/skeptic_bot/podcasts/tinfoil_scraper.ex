defmodule SkepticBot.Podcasts.TinfoilScraper do
  @moduledoc false

  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.DownloadingWorker
  alias SkepticBot.Podcasts.Episode

  @type episode_id :: String.t()
  @type start :: integer()

  @url "https://vid.samtripoli.com/api/v1/video-channels/tinfoilhat/videos?start=<start>&count=100&sort=-publishedAt&skipCount=false&nsfw=both"

  @spec scrape(start()) :: :ok | {:error, any()}
  def scrape(start \\ 0)

  def scrape(start) do
    url = String.replace(@url, "<start>", Integer.to_string(start))

    case get_req_client().make_request(url) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        Enum.each(body["data"], fn episode ->
          maybe_download_episode(episode)
        end)

        if Enum.empty?(body["data"]) do
          :ok
        else
          maybe_continue_scraping(start)
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

  @spec maybe_download_episode(Episode.t()) :: {:ok, Oban.Job.t()} | {:error, Ecto.Changeset.t()}
  def maybe_download_episode(episode) do
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
  end

  defp maybe_continue_scraping(start) do
    if get_current_mix_env() != :test, do: scrape(start + 100)
  end

  defp get_req_client do
    Application.get_env(:skeptic_bot, :req_client_module, SkepticBot.ReqClient)
  end

  defp get_current_mix_env do
    Application.get_env(:skeptic_bot, :mix_env)
  end
end
