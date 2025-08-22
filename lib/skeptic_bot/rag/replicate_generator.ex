defmodule SkepticBot.Rag.ReplicateGenerator do
  @moduledoc """
  Handles generation of responses using Replicate's language models.
  """
  alias LangChain.Message
  alias SkepticBot.Rag.Generator
  alias SkepticBot.ReplicateClient

  require Logger

  @behaviour Generator
  @behaviour ReplicateClient

  @model "openai/gpt-4.1"

  @impl ReplicateClient
  def get_type, do: "generation"

  @impl ReplicateClient
  def handle_output(output) when is_list(output), do: Enum.join(output)
  def handle_output(output), do: output

  @impl Generator
  def predict(messages) do
    input = %{
      length_penalty: 1.0,
      max_tokens: 512,
      presence_penalty: 0,
      prompt: format_messages(messages),
      temperature: 0.7,
      top_k: 0,
      top_p: 0.95
    }

    SkepticBot.ReplicateClient.start_prediction(
      __MODULE__,
      :processing_and_completed,
      @model,
      input
    )
  end

  defp format_messages(messages) do
    Enum.map_join(messages, "\n", fn
      %Message{role: :system, content: content} -> "System: #{content}\n"
      %Message{role: :user, content: content} -> "Human: #{content}\n"
      %Message{role: :assistant, content: content} -> "Assistant: #{content}\n"
    end)
  end
end
