defmodule SkepticBotWeb.Prompt.Helpers do
  @moduledoc """
  All the functions here are concerned with request processing
  """

  import Ecto.Query
  import Pgvector.Ecto.Query, only: [l2_distance: 2]

  alias SkepticBot.{Prompt, Rag, Repo, Podcasts.Episode}

  def return_question_changeset(list_of_episodes, query, description, question) do
    list_of_episode_ids =
      Enum.reduce(list_of_episodes, [], fn episode, list ->
        [%{episode_id: episode.id} | list]
      end)

    embedding_value = query <> " " <> description

    embedding = Rag.Embedding.generate(embedding_value)

    question_params = %{
      query: query,
      description: description,
      episodes: list_of_episode_ids,
      embedding: embedding
    }

    Prompt.change_question(question, question_params)
  end

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
          Map.put(episode, :thumbnail, "cover1.svg")
          |> Map.put(:video_length, "02:20:45")

        [episode | output_list]
      end)

    items
  end

  def get_related_questions(embedding, id) do
    questions =
      from(e in SkepticBot.Prompt.Question,
        select: %{id: e.id, description: e.description, title: e.query},
        where: e.id != ^id,
        order_by: [asc: l2_distance(e.embedding, ^embedding)],
        limit: 6
      )
      |> Repo.all()

    questions
  end

  def return_question_and_number(list) do
    Enum.with_index(list, fn element, index -> {element, index + 1} end)
  end

  def get_episodes(list_of_ids) do
    Enum.reduce(list_of_ids, [], fn map, list ->
      episode = Repo.get!(Episode, map.episode_id)

      [episode | list]
    end)
  end

  def format_description(string) do
    list_of_strings =
      String.split(string, "\n")
      |> Enum.filter(fn x -> x != "" end)

    Enum.map(list_of_strings, fn x ->
      (String.trim(x, "*")
       |> String.trim()) <> " "
    end)
    |> Enum.join()
  end

  def first_n_words(string, number_of_words) do
    string
    |> String.split(~r/\s+/, trim: true)
    |> Enum.take(number_of_words)
    |> Enum.join(" ")
  end
end
