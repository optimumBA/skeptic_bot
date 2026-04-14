defmodule SkepticBot.Podcasts.ThumbnailDownloader do
  @moduledoc """
  Takes care of downloading and uploading thumbnails to Tigris
  """
  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.Downloader
  alias SkepticBot.Podcasts.Episode
  alias SkepticBot.Storage.StorageProvider

  @type episode :: Episode.t()
  @type path :: String.t()
  @type podcast_name :: String.t()
  @type reason :: String.t()
  @type url :: String.t()

  @podcast_brokensimulation "Broken Simulation"
  @podcast_cashdaddies "Cash Daddies"
  @podcast_doomscrollin "Doom Scrollin"
  @podcast_tinfoilhat "Tin Foil Hat"
  @podcast_unionoftheunwanted "Union of the Unwanted"
  @podcast_zerowithsamtripoli "Zero with Sam Tripoli"
  @podcast_samtripoliwebsite [
    @podcast_brokensimulation,
    @podcast_cashdaddies,
    @podcast_doomscrollin,
    @podcast_tinfoilhat,
    @podcast_unionoftheunwanted,
    @podcast_zerowithsamtripoli
  ]
  @samtripoliwebsite_base_thumbnail_url "https://vid.samtripoli.com"

  @spec return_sam_podcast_ids :: [String.t()]
  def return_sam_podcast_ids,
    do:
      Enum.map(@podcast_samtripoliwebsite, fn name ->
        Podcasts.get_podcast_by_name(name).id
      end)

  @spec store_thumbnail(episode(), podcast_name()) :: :ok | {:error, reason()}
  def store_thumbnail(episode, podcast) when podcast in @podcast_samtripoliwebsite do
    thumbnail_url = @samtripoliwebsite_base_thumbnail_url <> episode.thumbnail
    download_and_store_thumbnail(episode, thumbnail_url)
  end

  def store_thumbnail(episode, _podcast) do
    download_and_store_thumbnail(episode, episode.thumbnail)
  end

  defp download_and_store_thumbnail(episode, thumbnail_url) do
    tmp_dir = System.tmp_dir!()
    new_thumbnail_path = Path.join(tmp_dir, "#{episode.id}_#{episode.external_id}.jpg")

    result =
      with {:ok, path} <- Downloader.download(thumbnail_url, new_thumbnail_path, :req),
           {:ok, public_thumbnail_url} <- StorageProvider.upload_file(path, "image/jpeg"),
           {:ok, _episode} <- Podcasts.update_episode(episode, %{thumbnail: public_thumbnail_url}) do
        :ok
      else
        {:error, reason} ->
          {:error, reason}
      end

    File.rm(new_thumbnail_path)
    result
  end
end
