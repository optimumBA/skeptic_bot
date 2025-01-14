defmodule SkepticBot.Podcasts.Episode do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "podcast_episodes" do
    field :description, :string
    field :embedding, Pgvector.Ecto.Vector
    field :external_id, :string
    field :title, :string
    field :transcription, :string, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(episode, attrs) do
    episode
    |> cast(attrs, [:description, :embedding, :external_id, :title])
    |> validate_required([:external_id, :title])
    |> unique_constraint(:external_id)
  end
end
