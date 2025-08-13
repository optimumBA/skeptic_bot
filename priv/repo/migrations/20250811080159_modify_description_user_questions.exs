defmodule SkepticBot.Repo.Migrations.ModifyDescriptionUserQuestions do
  use Ecto.Migration

  def change do
    execute(
      "ALTER TABLE user_questions ALTER COLUMN description DROP NOT NULL",
      "ALTER TABLE user_questions ALTER COLUMN description SET NOT NULL"
    )
  end
end
