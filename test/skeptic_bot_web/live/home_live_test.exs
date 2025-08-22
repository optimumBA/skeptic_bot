defmodule SkepticBotWeb.HomeLiveTest do
  use SkepticBotWeb.ConnCase, async: true

  import Mox
  import Phoenix.LiveViewTest
  import SkepticBot.PodcastsFixtures

  alias SkepticBot.PredictionHandler
  alias SkepticBot.Rag

  setup :verify_on_exit!

  describe "/" do
    test "shows heading and subtitle", %{conn: conn} do
      {:ok, view, html} = live(conn, ~p"/")
      assert html =~ ~r|<title>\s+Skeptic.bot\s+</title>|
      assert html =~ "Skeptic."
      assert html =~ "bot"
      assert html =~ "Questions everything"

      assert has_element?(view, ~s(input[placeholder*="Ask anything"]))
    end

    test "shows errors if the question is missing or is not meeting the required length", %{
      conn: conn
    } do
      {:ok, view, _html} = live(conn, ~p"/")

      assert view
             |> form("#question-input-form", user_question: %{query: ""})
             |> render_change() =~ "can&#39;t be blank"

      assert view
             |> form("#question-input-form", user_question: %{query: "de"})
             |> render_change() =~ "Your prompt must be at least 4 characters in length"

      refute view
             |> form("#question-input-form", user_question: %{query: "Who killed Two Pac Shakur"})
             |> render_change() =~ "Your prompt must be at least 4 characters in length"
    end

    test "page does not load on invalid data submission", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("#question-input-form", user_question: %{query: ""})
      |> render_submit()

      assert has_element?(view, ~s{div#loading-elements.hidden})
    end

    test "redirects to the question if episodes are found in the retrieval process", %{
      conn: conn
    } do
      embedding = embedding_fixture()
      episode = episode_fixture(embedding: embedding)
      _transcription = transcription_fixture(%{podcast_episode_id: episode.id})

      {:ok, view, _html} = live(conn, ~p"/")

      expect(Rag.MockEmbedder, :generate, fn _question_episodes ->
        {:ok, [embedding]}
      end)

      expect(Rag.MockGenerator, :predict, fn _messages ->
        {:ok, "Prediction process was successful"}
      end)

      allow(Rag.MockGenerator, self(), PredictionHandler)

      view
      |> form("#question-input-form", user_question: %{query: "American Ponzi with Lee Camp"})
      |> render_submit()

      assert has_element?(view, ~s{div#loading-elements})

      {path, _flash} = assert_redirect(view)
      assert path =~ ~r|/questions/|
    end

    test "renders an error message when no episodes are found in the retrieval process", %{
      conn: conn
    } do
      embedding = embedding_fixture()
      episode = episode_fixture(embedding: embedding_fixture())
      _transcription = transcription_fixture(%{podcast_episode_id: episode.id})

      {:ok, view, _html} = live(conn, ~p"/")

      expect(Rag.MockEmbedder, :generate, fn _question_episodes ->
        {:ok, [embedding]}
      end)

      view
      |> form("#question-input-form", user_question: %{query: "American Ponzi with Lee Camp"})
      |> render_submit()

      with_retries(
        fn ->
          assert render(view) =~
                   "Sorry, we currently have no podcasts discussing this topic."
        end,
        2
      )
    end

    test "renders an error message if the RAG process fails", %{
      conn: conn
    } do
      {:ok, view, _html} = live(conn, ~p"/")

      expect(Rag.MockEmbedder, :generate, fn _question_episodes ->
        {:error, "failed to generate embeddings"}
      end)

      view
      |> form("#question-input-form", user_question: %{query: "American Ponzi with Lee Camp"})
      |> render_submit()

      assert render(view) =~
               "An error occurred while processing your prompt. Please try again."
    end

    @tag :capture_log
    test "shows an error message if the RAG process crashes", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      expect(Rag.MockEmbedder, :generate, fn _question_episodes ->
        raise("failed to generate embeddings")
      end)

      view
      |> form("#question-input-form", user_question: %{query: "American Ponzi with Lee Camp"})
      |> render_submit()

      assert render(view) =~
               "An error occurred while processing your prompt. Please try again."
    end
  end
end
