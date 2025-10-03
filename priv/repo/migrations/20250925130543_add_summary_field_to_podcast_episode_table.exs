defmodule SkepticBot.Repo.Migrations.AddSummaryFieldToPodcastEpisodeTable do
  use Ecto.Migration

  def change do
    alter table(:podcast_episodes) do
      remove :description, :text
      add :summary, :text
      add :teaser, :text
    end
  end
end
