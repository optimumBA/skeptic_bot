defmodule SkepticBot.Storage.StorageProvider do
  @moduledoc false

  alias SkepticBot.Storage.TigrisStorageProvider

  @type filename :: String.t()
  @type reason :: String.t()

  @callback delete_file(filename()) :: :ok | {:error, reason()}

  @spec delete_file(filename()) :: :ok | {:error, reason()}
  def delete_file(filename), do: impl().delete_file(filename)

  defp impl, do: Application.get_env(:skeptic_bot, :storage_provider, TigrisStorageProvider)
end
