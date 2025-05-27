defmodule SkepticBotWeb.PodcastLiveTest do
  use SkepticBotWeb.ConnCase, async: true

  import Mox
  import Phoenix.LiveViewTest
  import SkepticBot.EpisodesFixtures

  alias SkepticBot.Prompts
  alias SkepticBot.Prompts.UserQuestion
  alias SkepticBot.Rag.EmbeddingMock

  setup :verify_on_exit!

  defp create_episodes_setup(%{conn: conn}) do
    embedding = embedding_fixture()
    description = description_fixture()

    %{conn: conn, embedding: embedding, description: description}
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

      {:ok, _view, html} = live(conn, "/podcasts/#{question.id}")

      assert html =~ question.query
      assert html =~ "Related Podcasts"
    end
  end
end
