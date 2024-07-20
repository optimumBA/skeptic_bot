defmodule SkepticBot.Rag.EmbeddingsGeneratingWorker do
  use Oban.Worker,
    queue: :generating_embeddings,
    unique: [period: :infinity, states: Oban.Job.states()]

  alias SkepticBot.Podcasts
  alias SkepticBot.Rag.Embedding

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    generate_embeddings(id)
  end

  defp generate_embeddings(episode_id) do
    with %Podcasts.Episode{} = episode <- Podcasts.get_episode(episode_id),
         {:ok, transcriptions} <- Podcasts.get_episode_transcriptions(episode_id) do
      embedding = Embedding.generate(episode.title <> "\n" <> transcriptions)
      Podcasts.update_episode(episode, %{embedding: embedding})

      batch_size = Application.get_env(:skeptic_bot, :embedding_generation)[:batch_size]

      Podcasts.while_streaming_episode_transcriptions(
        episode_id,
        batch_size,
        fn episode_transcriptions ->
          embeddings =
            episode_transcriptions
            |> Enum.map(& &1.transcription)
            |> Embedding.generate()

          episode_transcriptions
          |> Stream.with_index()
          |> Stream.each(fn {episode_transcription, i} ->
            Podcasts.update_episode_transcription(episode_transcription, %{
              embedding: Enum.at(embeddings, i)
            })
          end)
          |> Stream.run()
        end
      )

      :ok
    else
      reason ->
        reason
    end
  end

  def enqueue(attrs) do
    attrs
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
