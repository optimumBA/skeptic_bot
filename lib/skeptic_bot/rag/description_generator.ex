defmodule SkepticBot.Rag.DescriptionGenerator do
  @moduledoc """
  Generates descriptions for podcast episodes
  """

  alias LangChain.Message
  alias SkepticBot.Podcasts
  alias SkepticBot.Rag

  @type episode :: Podcasts.Episode.t()

  @spec generate_description(episode()) ::
          {:ok, String.t()}
          | {:error, String.t()}
  def generate_description(episode) do
    with {:ok, transcription} <- Podcasts.get_episode_transcriptions(episode.id),
         episode <- Map.put(episode, :trancription, transcription),
         prompt <- format_prompt(episode),
         {:ok, description} <- Rag.Generator.predict(prompt, :completed) do
      {:ok, description}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp format_prompt(episode) do
    system_message =
      ~s"""
      You are a skeptic.
      You don't believe official naratives and are open to all opinions.
      Read the content that I will give you and provide a summary of it in 1000 words or less.
      The summary should be very detailed and it should mention the names of the speakers if possible.
      You MUST not reveal your identity in the response.
      """

    [
      Message.new_system!(system_message)
    ] ++
      [
        Message.new_user!(~s"""
        Content:
        --------------------------------------
        #{format_episode(episode)}
        """)
      ]
  end

  defp format_episode(%Podcasts.Episode{} = episode) do
    ~s"""
    Description: #{episode.description || ""}
    Title: #{episode.title}
    Transcription: #{episode.transcription}
    """
  end
end
