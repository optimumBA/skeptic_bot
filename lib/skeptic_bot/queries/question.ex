defmodule SkepticBot.Prompt.UserQuestion do
  @moduledoc """
  The question the user asked stored in the DB
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias SkepticBot.Prompt.Episode

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "user_questions" do
    field :query, :string
    field :description, :string
    field :embedding, Pgvector.Ecto.Vector

    timestamps(type: :utc_datetime)
    embeds_many :episodes, Episode, on_replace: :delete
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:query, :description, :embedding])
    |> validate_required([:query, :description])
    |> validate_length(:query,
      min: 4,
      message: "Your prompt must be at least 4 characters in length"
    )
    |> cast_embed(:episodes)
  end

  @spec question_changeset(t(), map()) :: Ecto.Changeset.t()
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
