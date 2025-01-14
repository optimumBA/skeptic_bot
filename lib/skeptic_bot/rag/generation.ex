defmodule SkepticBot.Rag.Generation do
  alias LangChain.ChatModels.ChatOllamaAI
  alias LangChain.Chains.LLMChain

  def predict(messages) do
    {:ok, updated_chain} =
      %{llm: ChatOllamaAI.new!(%{model: "llama3.1"})}
      |> LLMChain.new!()
      |> LLMChain.add_messages(messages)
      |> LLMChain.run()

    updated_chain.last_message.content
  end
end
