defmodule SkepticBot.Repo.Migrations.CreatePodcastEpisodes do
  use Ecto.Migration

  def change do
    create table(:podcast_episodes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :external_id, :string, null: false
      add :title, :string, null: false
      add :description, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:podcast_episodes, [:external_id])
  end
end
