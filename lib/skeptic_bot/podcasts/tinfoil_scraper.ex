defmodule SkepticBot.Podcasts.TinfoilScraper do
  @moduledoc false

  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.DownloadingWorker
  alias SkepticBot.Podcasts.HttpClient

  @type episode_id :: String.t()
  @type start :: integer()

  @ignored_episodes [
    "Black Crack Robots:  Sam Tripoli's First Crowd Work Special",
    "Comic Crushes Cougar Heckler!",
    "Gay Heckler Gets Annihilated By Comic!",
    "POTTY MOUTH (Crowd Work Special #2) From Sam Tripoli",
    "Why is Everybody Gettin Quiet?"
  ]
  @podcast_brokensimulation "Broken Simulation"
  @podcast_cashdaddies "Cash Daddies"
  @podcast_doomscrollin "Doom Scrollin"
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
          podcasts = get_podcasts()
          process_episode(episode["name"], episode, podcasts)
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
            podcasts = get_podcasts()
            process_episode(episode["name"], episode, podcasts)
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp maybe_download_episode(episode, podcast) do
    unless Podcasts.episode_exists?(episode["uuid"]) do
      {:ok, %Podcasts.Episode{} = episode} =
        Podcasts.create_episode(%{
          "episode_length" => episode["duration"],
          "external_id" => episode["uuid"],
          "podcast_id" => podcast.id,
          "thumbnail" => episode["thumbnailPath"],
          "title" => episode["name"]
        })

      video_url = String.replace(@video_url, "<external_id>", episode.external_id)

      DownloadingWorker.enqueue(%{
        "id" => episode.id,
        "podcast" => podcast.name,
        "video_url" => video_url
      })
    end
  end

  defp process_episode(
         name,
         _episode,
         _podcasts
       )
       when name in @ignored_episodes,
       do: :ok

  defp process_episode(
         <<"Deep Conspiracy Rewinds", _remainder_title::binary>>,
         _episode,
         _podcasts
       ),
       do: :ok

  defp process_episode(
         <<"Punch Drunk Sports", _remainder_title::binary>>,
         _episode,
         _podcasts
       ),
       do: :ok

  defp process_episode(
         <<"Bad Advice", _remainder_title::binary>>,
         _episode,
         _podcasts
       ),
       do: :ok

  defp process_episode(
         <<"OnlyConspiracies", _remainder_title::binary>>,
         _episode,
         _podcasts
       ),
       do: :ok

  defp process_episode(
         <<"Saturday Night Deep Dives", _remainder_title::binary>>,
         _episode,
         _podcasts
       ),
       do: :ok

  defp process_episode(
         <<"OOTA", _remainder_title::binary>>,
         _episode,
         _podcasts
       ),
       do: :ok

  defp process_episode(
         <<"Opiate ", _remainder_title::binary>>,
         _episode,
         _podcasts
       ),
       do: :ok

  defp process_episode(
         <<"OPIATE FOR", _remainder_title::binary>>,
         _episode,
         _podcasts
       ),
       do: :ok

  defp process_episode(
         <<"Opiates Of", _remainder_title::binary>>,
         _episode,
         _podcasts
       ),
       do: :ok

  defp process_episode(
         <<"Broken Sim", _remainder_title::binary>>,
         _episode,
         _podcasts
       ),
       do: :ok

  defp process_episode(
         <<"BS Clips", _remainder_title::binary>>,
         _episode,
         _podcasts
       ),
       do: :ok

  defp process_episode(
         <<"Doom ", _remainder_title::binary>>,
         episode,
         podcasts
       ) do
    podcast = podcasts[@podcast_doomscrollin]
    maybe_download_episode(episode, podcast)
  end

  defp process_episode(
         <<"Doomscrollin", _remainder_title::binary>>,
         episode,
         podcasts
       ) do
    podcast = podcasts[@podcast_doomscrollin]
    maybe_download_episode(episode, podcast)
  end

  defp process_episode(
         <<"Cash Daddies", _remainder_title::binary>>,
         episode,
         podcasts
       ) do
    podcast = podcasts[@podcast_cashdaddies]
    maybe_download_episode(episode, podcast)
  end

  defp process_episode(
         <<"CashDaddies", _remainder_title::binary>>,
         episode,
         podcasts
       ) do
    podcast = podcasts[@podcast_cashdaddies]
    maybe_download_episode(episode, podcast)
  end

  defp process_episode(
         <<"Zero #", _remainder_title::binary>>,
         episode,
         podcasts
       ) do
    podcast = podcasts[@podcast_zerowithsamtripoli]
    maybe_download_episode(episode, podcast)
  end

  defp process_episode(
         <<"Union of the Unwanted", _remainder_title::binary>>,
         episode,
         podcasts
       ) do
    podcast = podcasts[@podcast_unionoftheunwanted]
    maybe_download_episode(episode, podcast)
  end

  defp process_episode(
         <<"The Union of The Unwanted", _remainder_title::binary>>,
         episode,
         podcasts
       ) do
    podcast = podcasts[@podcast_unionoftheunwanted]
    maybe_download_episode(episode, podcast)
  end

  defp process_episode(_episode_title, episode, podcasts) do
    podcast = podcasts[@podcast_tinfoilhat]
    maybe_download_episode(episode, podcast)
  end

  @spec get_podcasts :: map()
  def get_podcasts do
    podcast_list = [
      @podcast_brokensimulation,
      @podcast_cashdaddies,
      @podcast_doomscrollin,
      @podcast_tinfoilhat,
      @podcast_unionoftheunwanted,
      @podcast_zerowithsamtripoli
    ]

    podcast_list
    |> Enum.map(fn name -> {name, Podcasts.get_podcast_by_name(name)} end)
    |> Enum.into(%{})
  end
end
