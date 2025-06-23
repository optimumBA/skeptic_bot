defmodule SkepticBot.Storage.StorageProvider do
  @moduledoc false

  alias SkepticBot.Storage.TigrisStorageProvider

  @type filename :: String.t()
  @type filepath :: String.t()
  @type reason :: String.t()
  @type url :: String.t()

  @callback delete_file(filename()) :: :ok | {:error, reason()}
  @callback upload_file(filepath()) :: {:ok, url()} | {:error, reason()}

  @spec delete_file(filename()) :: :ok | {:error, reason()}
  def delete_file(filename), do: impl().delete_file(filename)

  @spec upload_file(filepath()) :: {:ok, url()} | {:error, reason()}
  def upload_file(filepath), do: impl().upload_file(filepath)

  defp impl, do: Application.get_env(:skeptic_bot, :storage_provider, TigrisStorageProvider)
end
