defmodule SkepticBot.Storage.StorageProvider do
  @moduledoc false

  alias SkepticBot.Storage.TigrisStorageProvider

  @type content_type :: String.t()
  @type filename :: String.t()
  @type filepath :: String.t()
  @type reason :: String.t()
  @type url :: String.t()

  @callback delete_file(filename()) :: :ok | {:error, reason()}
  @callback upload_file(filepath(), content_type()) :: {:ok, url()} | {:error, reason()}

  @spec delete_file(filename()) :: :ok | {:error, reason()}
  def delete_file(filename), do: impl().delete_file(filename)

  @spec upload_file(filepath(), content_type()) :: {:ok, url()} | {:error, reason()}
  def upload_file(filepath, content_type),
    do: impl().upload_file(filepath, content_type)

  defp impl, do: Application.get_env(:skeptic_bot, :storage_provider, TigrisStorageProvider)
end
