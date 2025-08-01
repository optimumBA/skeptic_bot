defmodule SkepticBot.Repo.Migrations.ChangeThumbnailTypeInPodcastEpisodes do
  use Ecto.Migration

  def change do
    alter table(:podcast_episodes) do
      modify :thumbnail, :text, from: :string
    end
  end
end
