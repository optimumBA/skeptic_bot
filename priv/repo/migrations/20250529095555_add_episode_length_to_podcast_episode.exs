defmodule SkepticBot.Repo.Migrations.AddEpisodeLengthToPodcastEpisode do
  use Ecto.Migration

  def change do
    alter table(:podcast_episodes) do
      add :episode_length, :integer
    end
  end
end
