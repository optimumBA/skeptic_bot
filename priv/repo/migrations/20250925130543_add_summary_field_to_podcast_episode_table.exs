defmodule SkepticBot.Repo.Migrations.AddSummaryFieldToPodcastEpisodeTable do
  use Ecto.Migration

  def change do
    alter table(:podcast_episodes) do
      add :summary, :text
    end
  end
end
