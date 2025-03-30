defmodule SkepticBot.Rag.Embedding do
  @behaviour SkepticBot.ReplicateClient
  require Logger

  @model "beautyyuyanli/multilingual-e5-large:a06276a89f1a902d5fc225a9ca32b6e8e6292b7f3b136518878da97c458e2bad"

  def get_type, do: "embedding generation"

  def handle_output(embeddings) do
    embeddings
  end

  def generate(text) when is_binary(text), do: generate([text])

  def generate(texts) when is_list(texts) do
    input = %{
      batch_size: 32,
      max_length: 512,
      normalize_embeddings: true,
      texts: Jason.encode!(texts)
    }

    SkepticBot.ReplicateClient.start_prediction(__MODULE__, @model, input)
  end
end
