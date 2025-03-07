defmodule SkepticBot.Prompt do
  defstruct [:name, :email]

  @types %{query: :string}

  alias SkepticBot.Prompt
  import Ecto.Changeset

  def changeset(%Prompt{} = prompt, attrs) do
    {prompt, @types}
    |> cast(attrs, Map.keys(@types))
    |> validate_required([:query])
    |> validate_length(:query,
      min: 4,
      message: "Your prompt must be at least 4 characters in length"
    )
  end
end
