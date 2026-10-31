defmodule SkepticBot.Repo.Migrations.AddUniqueIndexToPodcastEpisodeTranscriptionsTimestamps do
  use Ecto.Migration

  @spec change() :: term()
  def change do
    create unique_index(:podcast_episode_transcriptions, [:podcast_episode_id, :timestamp])
  end
end
