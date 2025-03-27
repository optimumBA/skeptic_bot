defmodule SkepticBot.Prompt.Question do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "user_questions" do
    field :query, :string
    field :description, :string

    timestamps(type: :utc_datetime)

    embeds_many :episodes, SkepticBot.Prompt.Episode, on_replace: :delete
  end

  def changeset(question, attrs) do
    question
    |> cast(attrs, [:query, :description])
    |> validate_required([:query, :description])
    |> validate_length(:query,
      min: 4,
      message: "Your prompt must be at least 4 characters in length"
    )
    |> cast_embed(:episodes)
  end

  def question_changeset(question, attrs) do
    question
    |> cast(attrs, [:query])
    |> validate_required([:query])
    |> validate_length(:query,
      min: 4,
      message: "Your prompt must be at least 4 characters in length"
    )
  end
end
