defmodule SkepticBot.Repo.Migrations.AddQuestion do
  use Ecto.Migration

  def change do
    create table(:user_questions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :query, :string
      add :description, :text

      add :episodes, :map

      timestamps(type: :utc_datetime)
    end
  end
end
