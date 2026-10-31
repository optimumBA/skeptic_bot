defmodule SkepticBot.Repo.Migrations.AddTitleToUserQuestions do
  use Ecto.Migration

  @spec change() :: term()
  def change do
    alter table(:user_questions) do
      add :title, :string
    end
  end
end
