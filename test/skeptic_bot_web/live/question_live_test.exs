defmodule SkepticBotWeb.QuestionLiveTest do
  use SkepticBotWeb.ConnCase, async: true

  import Mox
  import Phoenix.LiveViewTest
  import SkepticBot.EpisodesFixtures

  alias SkepticBot.Prompts
  alias SkepticBot.Prompts.UserQuestion
  alias SkepticBot.PromptsMock
  alias SkepticBot.Rag.EmbeddingMock
  alias SkepticBotWeb.PodcastComponents

  setup :verify_on_exit!

  defp create_episodes_setup(%{conn: conn}) do
    description = description_fixture()
    embedding = embedding_fixture()

    %{conn: conn, description: description, embedding: embedding}
  end

  describe "/podcasts/:id/" do
    setup [:create_episodes_setup]

    test "displays the question query and episodes' information plus \"Related Podcasts\"", %{
      conn: conn,
      description: description,
      embedding: embedding
    } do
      episodes = create_multiple_episodes(4)

      expect(EmbeddingMock, :generate, fn _embedding_value ->
        {:ok, [embedding]}
      end)

      {:ok, question} =
        Prompts.create_question(
          episodes,
          "Who Killed Two Pac Shakur",
          description,
          %UserQuestion{}
        )

      expect(PromptsMock, :get_question_episodes, 2, fn _question_episodes ->
        episodes
      end)

      {:ok, _view, html} = live(conn, "/questions/#{question.id}")

      assert html =~ question.query
      assert html =~ "Related Podcasts"

      Enum.each(episodes, fn episode ->
        assert html =~ PodcastComponents.first_n_words(episode.title, 2)
        assert html =~ PodcastComponents.get_time_from_seconds(episode.episode_length)
      end)
    end
  end
end
