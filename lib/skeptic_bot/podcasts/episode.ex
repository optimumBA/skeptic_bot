defmodule SkepticBot.Podcasts.Episode do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "podcast_episodes" do
    field :description, :string
    field :embedding, Pgvector.Ecto.Vector
    field :episode_length, :integer
    field :external_id, :string
    field :thumbnail, :string
    field :title, :string
    field :transcription, :string, virtual: true

    timestamps(type: :utc_datetime)
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(episode, attrs) do
    episode
    |> cast(attrs, [:description, :embedding, :episode_length, :external_id, :thumbnail, :title])
    |> validate_required([:episode_length, :external_id, :thumbnail, :title])
    |> unique_constraint(:external_id)
  end
end
