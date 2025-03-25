defmodule SkepticBot.Podcasts.DownloadingWorker do
  use Oban.Worker,
    queue: :downloading,
    unique: [period: :infinity, states: Oban.Job.states()]

  alias SkepticBot.Podcasts.TranscribingWorker

  @url "https://vid.samtripoli.com/download/streaming-playlists/hls/videos/<external_id>-0-fragmented.mp4"

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id, "external_id" => external_id}}) do
    download_episode(id, external_id)
    TranscribingWorker.enqueue(%{"id" => id})

    :ok
  end

  defp download_episode(id, external_id) do
    dir = Path.join([Application.app_dir(:skeptic_bot, "priv"), "podcasts", "audio"])
    File.mkdir_p!(dir)
    path = Path.join(dir, "#{id}.mp4")

    File.rm(path)

    @url
    |> String.replace("<external_id>", external_id)
    |> Req.get!(into: File.stream!(path))
  end

  def enqueue(attrs) do
    attrs
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
