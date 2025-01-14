defmodule SkepticBot.Podcasts.TranscribingWorker do
  use Oban.Worker,
    queue: :transcribing,
    unique: [period: :infinity, states: Oban.Job.states()]

  alias SkepticBot.Podcasts
  alias SkepticBot.Rag.EmbeddingsGeneratingWorker
  alias SkepticBot.Transcription

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    transcribe_episode(id)
    EmbeddingsGeneratingWorker.enqueue(%{"id" => id})

    :ok
  end

  defp transcribe_episode(id) do
    dir = Path.join([Application.app_dir(:skeptic_bot, "priv"), "podcasts", "audio"])
    path = Path.join(dir, "#{id}.mp3")

    for chunk <- Transcription.transcribe(path) do
      Podcasts.create_episode_transcription(%{
        podcast_episode_id: id,
        timestamp: %{months: 0, days: 0, secs: floor(chunk.start_timestamp_seconds)},
        transcription: chunk.text
      })
    end
  end

  def enqueue(attrs) do
    attrs
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
