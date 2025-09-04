defmodule SkepticBot.Podcasts.ThumbnailDownloader do
  @moduledoc """
  Takes care of downloading and uploading thumbnails to Tigris
  """

  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.Downloader
  alias SkepticBot.Storage.StorageProvider

  @type id :: String.t()
  @type path :: String.t()
  @type podcast_name :: String.t()
  @type reason :: String.t()
  @type url :: String.t()

  @podcast_tinfoilhat "Tin Foil Hat"
  @tinfoil_base_thumbnail_url "https://vid.samtripoli.com"

  @spec store_thumbnail(id(), podcast_name()) :: :ok | {:error, reason()}
  def store_thumbnail(id, @podcast_tinfoilhat) do
    episode = Podcasts.get_episode(id)
    thumbnail_url = @tinfoil_base_thumbnail_url <> episode.thumbnail
    download_and_store_thumbnail(episode, thumbnail_url)
  end

  def store_thumbnail(id, _podcast) do
    episode = Podcasts.get_episode(id)
    download_and_store_thumbnail(episode, episode.thumbnail)
  end

  defp download_and_store_thumbnail(episode, thumbnail_url) do
    tmp_dir = System.tmp_dir!()
    new_thumbnail_path = Path.join(tmp_dir, "#{episode.id}_#{episode.external_id}.jpg")

    result =
      with {:ok, path} <- Downloader.download(thumbnail_url, new_thumbnail_path, :req),
           {:ok, public_url} <- StorageProvider.upload_file(path, "image/jpeg"),
           {:ok, _episode} <- Podcasts.update_episode(episode, %{thumbnail: public_url}) do
        :ok
      else
        {:error, reason} ->
          {:error, reason}
      end

    File.rm(new_thumbnail_path)
    result
  end
end
