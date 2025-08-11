defmodule SkepticBot.Repo.Migrations.ModifyDescriptionUserQuestions do
  use Ecto.Migration

  def change do
    alter table(:user_questions) do
      modify :description, :text, null: true
    end
  end
end
