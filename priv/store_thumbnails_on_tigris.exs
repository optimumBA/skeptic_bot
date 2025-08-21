defmodule StoreThumbnailsOnTigris do
  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.Downloader
  alias SkepticBot.Podcasts.Episode
  alias SkepticBot.Repo
  alias SkepticBot.Storage.TigrisStorageProvider

  @base_url "https://vid.samtripoli.com/"

  def start do
    Episode
    |> Repo.all()
    |> Enum.each(&download_and_store/1)
  end

  def download_and_store(episode) do
    url = @base_url <> episode.thumbnail

    tmp_dir = System.tmp_dir!()
    thumbnail_path = Path.join(tmp_dir, "#{episode.id}_#{episode.external_id}.jpg")

    with {:ok, path} <- Downloader.download(url, thumbnail_path),
         {:ok, public_url} <- TigrisStorageProvider.upload_file(path, "image/jpeg"),
         {:ok, episode} <- Podcasts.update_episode(episode, %{thumbnail: public_url}) do
      :ok
    else
      {:error, reason} ->
        {:error, reason}
    end

    File.rm(thumbnail_path)
  end
end

StoreThumbnailsOnTigris.start()
