defmodule SkepticBot.Podcasts.DownloadingWorker do
  @moduledoc """
  Handles downloading of podcast episodes from external sources.
  Downloads the media file and prepares it for transcoding.
  """

  use Oban.Worker,
    max_attempts: 5,
    queue: :downloading,
    unique: [period: :infinity, states: Oban.Job.states()]

  alias SkepticBot.Podcasts.TranscodingWorker

  require Logger

  @type job :: Oban.Job.t()

  @url "https://vid.samtripoli.com/download/streaming-playlists/hls/videos/<external_id>-0-fragmented.mp4"

  @impl Oban.Worker
  @spec perform(job()) :: :ok
  def perform(%Oban.Job{args: %{"id" => id, "external_id" => external_id}}) do
    download_episode(id, external_id)
    TranscodingWorker.enqueue(%{"id" => id})

    :ok
  end

  @spec download_episode(String.t(), String.t()) :: Req.Response.t()
  defp download_episode(id, external_id) do
    dir = Path.join([Application.app_dir(:skeptic_bot, "priv"), "podcasts", "video"])
    File.mkdir_p!(dir)
    path = Path.join(dir, "#{id}.mp4")

    File.rm(path)

    @url
    |> String.replace("<external_id>", external_id)
    |> Req.get!(into: File.stream!(path))
  end

  @spec enqueue(map()) :: {:ok, job()} | {:error, Ecto.Changeset.t()}
  def enqueue(attrs) do
    attrs
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
