defmodule SkepticBot.Repo.Migrations.AddEmbeddingToPodcastEpisodesAndPodcastEpisodeTranscriptions do
  use Ecto.Migration

  def change do
    embedding_dimensions = Application.get_env(:skeptic_bot, :embedding_generation)[:dimensions]

    execute "CREATE EXTENSION IF NOT EXISTS vector", "DROP EXTENSION IF EXISTS vector"

    alter table(:podcast_episodes) do
      add :embedding, :vector, null: true, size: embedding_dimensions
    end

    create index(
             :podcast_episodes,
             ["embedding vector_l2_ops"],
             using: :ivfflat,
             options: "lists = 100"
           )

    alter table(:podcast_episode_transcriptions) do
      add :embedding, :vector, null: true, size: embedding_dimensions
    end

    create index(
             :podcast_episode_transcriptions,
             ["embedding vector_l2_ops"],
             using: :ivfflat,
             options: "lists = 100"
           )
  end
end
