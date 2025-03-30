defmodule SkepticBot.Rag.Generation do
  @behaviour SkepticBot.ReplicateClient
  require Logger
  alias LangChain.Message

  @model "meta/meta-llama-3-8b-instruct"

  def get_type, do: "generation"

  def handle_output(output) when is_list(output), do: Enum.join(output)
  def handle_output(output), do: output

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

    SkepticBot.ReplicateClient.start_prediction(__MODULE__, @model, input)
  end

  defp format_messages(messages) do
    messages
    |> Enum.map(fn
      %Message{role: :system, content: content} -> "System: #{content}\n"
      %Message{role: :user, content: content} -> "Human: #{content}\n"
      %Message{role: :assistant, content: content} -> "Assistant: #{content}\n"
    end)
    |> Enum.join("\n")
  end
end
