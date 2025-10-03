defmodule SkepticBot.Rag do
  @moduledoc """
  Implements a Retrieval-Augmented Generation system for podcast content.
  Combines vector search retrieval with language model generation to create contextual responses.
  """

  alias LangChain.Message
  alias SkepticBot.Podcasts
  alias SkepticBot.Rag

  @type embedding :: [float()]

  @spec generate_embedding(String.t()) ::
          {:ok, {list(), embedding()}}
          | {:error, any()}
  def generate_embedding(query) do
    case Rag.Embedder.generate("query: " <> query) do
      {:ok, [embedding]} ->
        case Rag.Retrieval.retrieve(embedding) do
          [] ->
            {:error, :no_episodes_found}

          context ->
            {:ok, {context, embedding}}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec predict_query(list(), String.t()) ::
          {:ok, String.t()}
          | {:error, String.t()}
  def predict_query(context, query) do
    with prompt <- format_prompt(context, query),
         {:ok, response} <- Rag.Generator.predict(prompt, :processing_and_completed) do
      {:ok, response}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp format_prompt(context, query) do
    system_message =
      ~s"""
      You are a skeptic.
      You don't believe official naratives and are open to all opinions.
      Respond to the following query using only the context I pass to you and no other knowledge.
      Context is composed of conspiracy podcast episodes talking about various topics.
      Avoid mentioning me in the response. For example avoid something like : "you provided some episodes..."
      Avoid mentioning "the context" and the exact episodes where a topic is being discussed.
      You MUST not reveal your identity or that you are a skeptic.
      Your response MUST inlude a title and a description.
      The description is a paragraph (MUST not EXCEED 200 words) of your response to the query using only the context I pass to you.
      Please refrain from providing exact details in the description, rather provide just enough to capture the interest of the reader.
      Kindly urge the reader to listen to the podcast episodes to get the full story.
      The title (MUST be one statement) MUST clearly explain what the entire response is about.
      Your response MUST be in the following format with the title coming first with its value
      then the description coming second with its corresponding value. They should be separated by the "$&$" signs.
      Here are some examples:

      Example 1 : "Global Controls$&$The world is controlled by elite individuals"
      Example 2 : "American Ponzi schemes$&$Wake up now before it is too late"
      """

    [
      Message.new_system!(system_message)
    ] ++
      [
        Message.new_user!(~s"""
        Context:
        --------------------------------------
        #{Enum.map_join(context, "\n--------------------------------------\n", &format_episode/1)}
        --------------------------------------
        Query: #{query}
        """)
      ]
  end

  defp format_episode(%Podcasts.Episode{} = episode) do
    ~s"""
    Episode ID: #{episode.id}
    Title: #{episode.title}
    Summary: #{episode.summary}
    """
  end
end
