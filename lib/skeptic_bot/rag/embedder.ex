defmodule SkepticBot.Rag.Embedder do
  @moduledoc false

  alias SkepticBot.Rag.ReplicateEmbedder

  @type embedding :: [float()]
  @type reason :: String.t()
  @type text :: String.t()

  @callback generate([text()]) :: {:ok, [embedding()]} | {:error, reason()}

  @spec generate(text()) :: {:ok, [embedding()]} | {:error, reason()}
  def generate(text) when is_binary(text), do: generate([text])

  @spec generate([text()]) :: {:ok, [embedding()]} | {:error, reason()}
  def generate(texts) when is_list(texts) do
    impl().generate(texts)
  end

  defp impl, do: Application.get_env(:skeptic_bot, :embedder, ReplicateEmbedder)
end
