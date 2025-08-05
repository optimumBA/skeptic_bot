defmodule SkepticBot.Podcasts.Podcasts do
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

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(episode, attrs) do
    episode
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
