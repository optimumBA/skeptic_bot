defmodule SkepticBotWeb.PromptHelpers do
  @moduledoc """
  All the functions here are concerned with request processing
  """

  alias SkepticBot.Podcasts.Episode
  alias SkepticBot.Prompt
  alias SkepticBot.Rag
  alias SkepticBot.Repo

  @type episode :: map()
  @type prompt_episode :: map()
  @type question :: map()

  @spec return_question_changeset([episode()], String.t(), String.t(), question()) ::
          Ecto.Changeset.t()
  def return_question_changeset(list_of_episodes, query, description, question) do
    list_of_episode_ids =
      Enum.reduce(list_of_episodes, [], fn episode, list ->
        [%{episode_id: episode.id} | list]
      end)

    embedding_value = query <> " " <> description
    {:ok, [embedding]} = Rag.Embedding.generate(embedding_value)

    question_params = %{
      query: query,
      description: description,
      episodes: list_of_episode_ids,
      embedding: embedding
    }

    Prompt.change_question(question, question_params)
  end

  @spec format_episodes([episode()]) :: [episode()]
  def format_episodes(episodes_list) do
    items =
      Enum.reduce(episodes_list, [], fn episode, output_list ->
        episode =
          case is_struct(episode) do
            true ->
              episode = Map.from_struct(episode)

              episode

            false ->
              episode
          end

        episode =
          episode
          |> Map.put(:thumbnail, "cover1.svg")
          |> Map.put(:video_length, "02:20:45")

        [episode | output_list]
      end)

    items
  end

  @spec get_episodes([prompt_episode()]) :: [episode()]
  def get_episodes(list_of_ids) do
    Enum.reduce(list_of_ids, [], fn map, list ->
      episode = Repo.get!(Episode, map.episode_id)

      [episode | list]
    end)
  end

  @spec first_n_words(String.t(), integer()) :: String.t()
  def first_n_words(string, number_of_words) do
    string
    |> String.split(~r/\s+/, trim: true)
    |> Enum.take(number_of_words)
    |> Enum.join(" ")
  end
end
