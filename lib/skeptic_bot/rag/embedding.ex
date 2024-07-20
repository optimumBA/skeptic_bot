defmodule SkepticBot.Rag.Embedding do
  require Logger

  def serving do
    batch_size = Application.get_env(:skeptic_bot, :embedding_generation)[:batch_size]
    repo = Application.get_env(:skeptic_bot, :embedding_generation)[:repo]

    {:ok, model_info} = Bumblebee.load_model(repo)
    {:ok, tokenizer} = Bumblebee.load_tokenizer(repo)

    Bumblebee.Text.text_embedding(model_info, tokenizer,
      compile: [batch_size: batch_size, sequence_length: 512],
      embedding_processor: :l2_norm,
      defn_options: [compiler: EXLA]
    )
  end

  def generate(text) when is_list(text) do
    for result <- Nx.Serving.batched_run(__MODULE__, text), do: result.embedding
  end

  def generate(text) do
    %{embedding: embedding} = Nx.Serving.batched_run(__MODULE__, text)

    embedding
  end
end
