defmodule SkepticBot.Podcasts.DownloadingWorker do
  @moduledoc """
  Handles combined downloading and transcoding of podcast episodes from external sources.
  Downloads the media file, transcodes it, and uploads the audio to Tigris.
  Uses FLAME to handle both processes in a separate memory space.
  """

  use Oban.Worker,
    max_attempts: 5,
    queue: :downloading,
    unique: [period: :infinity, states: Oban.Job.states()]

  alias SkepticBot.Downloader
  alias SkepticBot.Podcasts.TranscribingWorker

  require Logger

  @type job :: Oban.Job.t()

  @url "https://vid.samtripoli.com/download/streaming-playlists/hls/videos/<external_id>-0-fragmented.mp4"

  @impl Oban.Worker
  @spec perform(job()) :: :ok | {:error, String.t()}
  def perform(%Oban.Job{args: %{"id" => id, "external_id" => external_id}}) do
    url = String.replace(@url, "<external_id>", external_id)

    case Downloader.process_with_flame(id, url, external_id) do
      {:ok, audio_url} ->
        TranscribingWorker.enqueue(%{"id" => id, "audio_url" => audio_url})
        :ok

      {:error, reason} ->
        Logger.error("Failed to process episode: #{id}, reason: #{reason}")
        {:error, reason}
    end
  end

  @spec enqueue(map()) :: {:ok, job()} | {:error, Ecto.Changeset.t()}
  def enqueue(attrs) do
    attrs
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
