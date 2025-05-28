defmodule SkepticBot.Repo.Migrations.AddThumbnailToPodcastEpisode do
  use Ecto.Migration

  def change do
    alter table(:podcast_episodes) do
      add :thumbnail, :string
      add :episode_length, :integer
    end
  end
end
