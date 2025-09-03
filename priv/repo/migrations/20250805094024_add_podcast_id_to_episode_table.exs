defmodule SkepticBot.Repo.Migrations.AddPodcastIdToEpisodeTable do
  use Ecto.Migration

  def change do
    alter table(:podcast_episodes) do
      add :podcast_id,
          references(:podcasts, on_delete: :delete_all, type: :binary_id)
    end
  end
end
