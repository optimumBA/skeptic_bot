defmodule SkepticBotWeb.PodcastLiveTest do
  use SkepticBotWeb.ConnCase, async: true

  import Mox
  import Phoenix.LiveViewTest
  import SkepticBot.EpisodesFixtures

  alias SkepticBot.Prompts
  alias SkepticBot.Prompts.UserQuestion
  alias SkepticBot.PromptsMock
  alias SkepticBot.Rag.EmbeddingMock

  setup :verify_on_exit!

  defp create_episodes_setup(%{conn: conn}) do
    description = description_fixture()
    embedding = embedding_fixture()

    %{conn: conn, description: description, embedding: embedding}
  end

  describe "/" do
    setup [:create_episodes_setup]

    test "displays the question query and \"Related Podcasts\"", %{
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

      {:ok, view, html} = live(conn, "/podcasts/#{question.id}")

      expect(PromptsMock, :get_question_episodes, fn _question_episodes ->
        episodes
      end)

      # open_browser(view)

      assert html =~ question.query
      assert html =~ "Related Podcasts"
    end
  end
end
