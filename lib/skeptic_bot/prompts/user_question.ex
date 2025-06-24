defmodule SkepticBot.Prompts.UserQuestion do
  @moduledoc """
  The question the user asked stored in the DB
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias SkepticBot.Prompts.Episode

  @type attrs :: map()
  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "user_questions" do
    field :description, :string
    field :embedding, Pgvector.Ecto.Vector
    field :query, :string

    timestamps(type: :utc_datetime)

    embeds_many :episodes, Episode, on_replace: :delete
  end

  @spec changeset(t(), attrs()) :: Ecto.Changeset.t()
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:description, :embedding, :query])
    |> validate_required([:description, :embedding, :query])
    |> validate_length(:query,
      min: 4,
      message: "Your prompt must be at least 4 characters in length"
    )
    |> cast_embed(:episodes)
  end

  @spec query_changeset(t(), attrs()) :: Ecto.Changeset.t()
  def query_changeset(question, attrs) do
    question
    |> cast(attrs, [:query])
    |> validate_required([:query])
    |> validate_length(:query,
      min: 4,
      message: "Your prompt must be at least 4 characters in length"
    )
  end
end
