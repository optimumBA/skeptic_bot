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
      # Use a consistent embedding value that will match within the distance threshold
      embedding = List.duplicate(0.1, 1024)
      episode = episode_fixture(embedding: embedding)

      # Add a transcription with an embedding too
      _transcription =
        transcription_fixture(%{
          podcast_episode_id: episode.id,
          embedding: List.duplicate(0.11, 1024),
          transcription: "Test transcription content"
        })

      {:ok, view, _html} = live(conn, ~p"/")

      # Use the same embedding for search that we used for the episode
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

      {path, _flash} = assert_redirect(view)
      assert path =~ ~r|/questions/|
    end

    test "renders an error message when no episodes are found in the retrieval process", %{
      conn: conn
    } do
      # Create search embedding and episode with very different embedding to ensure no match
      search_embedding = List.duplicate(0.1, 1024)
      # Very different from search_embedding
      episode_embedding = List.duplicate(0.9, 1024)

      episode = episode_fixture(embedding: episode_embedding)
      _transcription = transcription_fixture(%{podcast_episode_id: episode.id})

      {:ok, view, _html} = live(conn, ~p"/")

      expect(Rag.MockEmbedder, :generate, fn _question_episodes ->
        {:ok, [search_embedding]}
      end)

      view
      |> form("#question-input-form", user_question: %{query: "American Ponzi with Lee Camp"})
      |> render_submit()

      # The loading elements should show immediately after submit
      # Since no episodes are found, the error message should appear quickly
      # Let's check that the error message eventually appears instead

      # Wait for the error message to appear
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
