defmodule SkepticBot.Repo.Migrations.CreatePodcastEpisodeTranscriptions do
  use Ecto.Migration

  def change do
    create table(:podcast_episode_transcriptions, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :podcast_episode_id,
          references(:podcast_episodes, on_delete: :delete_all, type: :binary_id),
          null: false

      add :timestamp, :interval, null: false
      add :transcription, :text, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:podcast_episode_transcriptions, [:podcast_episode_id])
    create index(:podcast_episode_transcriptions, [:timestamp])
  end
end
