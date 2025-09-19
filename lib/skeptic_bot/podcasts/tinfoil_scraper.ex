defmodule SkepticBot.Podcasts.TinfoilScraper do
  @moduledoc false

  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.DownloadingWorker
  alias SkepticBot.Podcasts.HttpClient

  @type episode_id :: String.t()
  @type start :: integer()

  @podcast_cashdaddies "Cash Daddies"
  @podcast_doomscrollin "Doom Scrollin"
  @podcast_opiateoftheasses "Opiate of the Asses"
  @podcast_tinfoilhat "Tin Foil Hat"
  @podcast_unionoftheunwanted "Union of the Unwanted"
  @podcast_zerowithsamtripoli "Zero with Sam Tripoli"
  @url "https://vid.samtripoli.com/api/v1/video-channels/tinfoilhat/videos?start=<start>&count=100&sort=-publishedAt&skipCount=false&nsfw=both"
  @video_url "https://vid.samtripoli.com/download/streaming-playlists/hls/videos/<external_id>-0-fragmented.mp4"

  @spec get_url() :: String.t()
  def get_url, do: @url

  @spec scrape(start()) :: :ok | {:error, any()}
  def scrape(start \\ 0)

  def scrape(start) do
    url = String.replace(@url, "<start>", Integer.to_string(start))

    case HttpClient.make_request(url) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        Enum.each(body["data"], fn episode ->
          podcast_ids = get_podcast_ids()
          podcast_id = return_podcast_id(episode["name"], podcast_ids)
          maybe_download_episode(episode, podcast_id)
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

    case HttpClient.make_request(url) do
      {:ok, %Req.Response{status: 200, body: %{"data" => []}}} ->
        {:error, :episode_not_found}

      {:ok, %Req.Response{status: 200, body: body}} ->
        episode = Enum.find(body["data"], fn episode -> episode["uuid"] == uuid end)

        case episode do
          nil ->
            scrape_episode(uuid, start + 100)

          episode ->
            podcast_ids = get_podcast_ids()
            podcast_id = return_podcast_id(episode["name"], podcast_ids)
            maybe_download_episode(episode, podcast_id)
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp maybe_download_episode(episode, podcast_id) do
    unless Podcasts.episode_exists?(episode["uuid"]) do
      {:ok, %Podcasts.Episode{} = episode} =
        Podcasts.create_episode(%{
          "description" => episode["description"],
          "episode_length" => episode["duration"],
          "external_id" => episode["uuid"],
          "podcast_id" => podcast_id,
          "thumbnail" => episode["thumbnailPath"],
          "title" => episode["name"]
        })

      video_url = String.replace(@video_url, "<external_id>", episode.external_id)

      DownloadingWorker.enqueue(%{
        "id" => episode.id,
        "podcast" => @podcast_tinfoilhat,
        "video_url" => video_url
      })
    end
  end

  defp return_podcast_id(
         <<"Doom ", _remainder_title::binary>>,
         [_podcast_id, podcast_2_id, _podcast_3_id, _podcast_4_id, _podcast_5_id, _podcast_6_id]
       ) do
    podcast_2_id
  end

  defp return_podcast_id(
         <<"Doomscrollin", _remainder_title::binary>>,
         [_podcast_id, podcast_2_id, _podcast_3_id, _podcast_4_id, _podcast_5_id, _podcast_6_id]
       ) do
    podcast_2_id
  end

  defp return_podcast_id(
         <<"Cash Daddies", _remainder_title::binary>>,
         [_podcast_id, _podcast_2_id, podcast_3_id, _podcast_4_id, _podcast_5_id, _podcast_6_id]
       ) do
    podcast_3_id
  end

  defp return_podcast_id(
         <<"CashDaddies", _remainder_title::binary>>,
         [_podcast_id, _podcast_2_id, podcast_3_id, _podcast_4_id, _podcast_5_id, _podcast_6_id]
       ) do
    podcast_3_id
  end

  defp return_podcast_id(
         <<"Opiate ", _remainder_title::binary>>,
         [_podcast_id, _podcast_2_id, _podcast_3_id, podcast_4_id, _podcast_5_id, _podcast_6_id]
       ) do
    podcast_4_id
  end

  defp return_podcast_id(
         <<"OPIATE FOR", _remainder_title::binary>>,
         [_podcast_id, _podcast_2_id, _podcast_3_id, podcast_4_id, _podcast_5_id, _podcast_6_id]
       ) do
    podcast_4_id
  end

  defp return_podcast_id(
         <<"Opiates Of", _remainder_title::binary>>,
         [_podcast_id, _podcast_2_id, _podcast_3_id, podcast_4_id, _podcast_5_id, _podcast_6_id]
       ) do
    podcast_4_id
  end

  defp return_podcast_id(
         <<"Zero #", _remainder_title::binary>>,
         [_podcast_id, _podcast_2_id, _podcast_3_id, _podcast_4_id, podcast_5_id, _podcast_6_id]
       ) do
    podcast_5_id
  end

  defp return_podcast_id(
         <<"Union of the Unwanted", _remainder_title::binary>>,
         [_podcast_id, _podcast_2_id, _podcast_3_id, _podcast_4_id, _podcast_5_id, podcast_6_id]
       ) do
    podcast_6_id
  end

  defp return_podcast_id(
         <<"The Union of The Unwanted", _remainder_title::binary>>,
         [_podcast_id, _podcast_2_id, _podcast_3_id, _podcast_4_id, _podcast_5_id, podcast_6_id]
       ) do
    podcast_6_id
  end

  defp return_podcast_id(_episode_title, [
         podcast_id,
         _podcast_2_id,
         _podcast_3_id,
         _podcast_4_id,
         _podcast_5_id,
         _podcast_6_id
       ]),
       do: podcast_id

  defp get_podcast_ids do
    podcast = Podcasts.get_podcast_by_name(@podcast_tinfoilhat)
    podcast_2 = Podcasts.get_podcast_by_name(@podcast_doomscrollin)
    podcast_3 = Podcasts.get_podcast_by_name(@podcast_cashdaddies)
    podcast_4 = Podcasts.get_podcast_by_name(@podcast_opiateoftheasses)
    podcast_5 = Podcasts.get_podcast_by_name(@podcast_zerowithsamtripoli)
    podcast_6 = Podcasts.get_podcast_by_name(@podcast_unionoftheunwanted)

    [podcast.id, podcast_2.id, podcast_3.id, podcast_4.id, podcast_5.id, podcast_6.id]
  end
end
