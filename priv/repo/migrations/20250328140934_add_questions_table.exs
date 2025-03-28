defmodule SkepticBot.Repo.Migrations.AddQuestionsTable do
  use Ecto.Migration

  def change do
    embedding_dimensions = Application.get_env(:skeptic_bot, :embedding_generation)[:dimensions]

    create table(:user_questions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :query, :string
      add :description, :text

      add :episodes, :map
      add :embedding, :vector, null: true, size: embedding_dimensions

      timestamps(type: :utc_datetime)
    end

    create index(
             :user_questions,
             ["embedding vector_l2_ops"],
             using: :ivfflat,
             options: "lists = 100"
           )
  end
end
