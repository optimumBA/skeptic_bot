defmodule SkepticBot.Rag.Embedder do
  @moduledoc false

  alias SkepticBot.Rag.ReqEmbedder

  @type embedding :: [float()]
  @type text :: String.t()

  @callback generate([text()]) :: {:ok, [embedding()]} | {:error, any()}

  @spec generate(text()) :: {:ok, [embedding()]} | {:error, any()}
  def generate(text) when is_binary(text), do: generate([text])

  @spec generate([text()]) :: {:ok, [embedding()]} | {:error, any()}
  def generate(texts) when is_list(texts) do
    impl().generate(texts)
  end

  defp impl, do: Application.get_env(:skeptic_bot, :embedder, ReqEmbedder)
end
