defmodule SkepticBot.Rag.ReplicateEmbedder do
  @moduledoc """
  Handles generation of text embeddings for the RAG system.
  Uses multilingual embedding models to convert text into dense vector representations.
  """

  alias SkepticBot.Rag.Embedder
  alias SkepticBot.ReplicateClient

  require Logger

  @behaviour Embedder
  @behaviour SkepticBot.ReplicateClient

  @model "beautyyuyanli/multilingual-e5-large:a06276a89f1a902d5fc225a9ca32b6e8e6292b7f3b136518878da97c458e2bad"

  @impl ReplicateClient
  def get_type, do: "embedding generation"

  @impl ReplicateClient
  def handle_output(embeddings) do
    embeddings
  end

  @impl Embedder
  def generate(texts) do
    input = %{
      batch_size: 32,
      max_length: 512,
      normalize_embeddings: true,
      texts: Jason.encode!(texts)
    }

    SkepticBot.ReplicateClient.start_prediction(__MODULE__, @model, input)
  end
end
