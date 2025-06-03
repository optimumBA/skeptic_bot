defmodule SkepticBotWeb.QuestionLiveTest do
  use SkepticBotWeb.ConnCase, async: true

  import Mox
  import Phoenix.LiveViewTest
  import SkepticBot.EpisodesFixtures

  alias SkepticBot.PromptsMock
  alias SkepticBotWeb.PodcastComponents

  setup :verify_on_exit!

  defp create_episodes_setup(%{conn: conn}) do
    description = description_fixture()
    embedding = embedding_fixture()
    question = question_fixture(%{query: "American Ponzi with Lee Camp"})

    %{conn: conn, description: description, embedding: embedding, question: question}
  end

  describe "/questions/:id/" do
    setup [:create_episodes_setup]

    test "displays the question query and episodes' information plus \"Related Podcasts\"", %{
      conn: conn,
      question: question
    } do
      episodes = create_multiple_episodes(4)

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
