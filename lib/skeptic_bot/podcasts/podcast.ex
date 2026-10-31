defmodule SkepticBot.Podcasts.Podcast do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "podcasts" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @type changeset :: Ecto.Changeset.t()
  @type params :: map()

  @spec changeset(t(), params()) :: changeset()
  def changeset(episode, attrs) do
    episode
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
