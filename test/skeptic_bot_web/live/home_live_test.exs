defmodule SkepticBotWeb.HomeLiveTest do
  use SkepticBotWeb.ConnCase, async: true

  import Mox
  import Phoenix.LiveViewTest
  import SkepticBot.PodcastsFixtures

  alias SkepticBot.Rag

  setup :verify_on_exit!

  defp create_prompt_resources(%{conn: conn}) do
    embedding = embedding_fixture()
    episode = episode_fixture()
    response = "A simple response from a large language model"

    %{
      conn: conn,
      embedding: embedding,
      episode: episode,
      response: response
    }
  end

  describe "/" do
    setup [:create_prompt_resources]

    test "shows heading and subtitle", %{conn: conn} do
      {:ok, view, html} = live(conn, "/")
      assert html =~ "Skeptic."
      assert html =~ "bot"
      assert html =~ "Questions everything"

      assert has_element?(view, ~s(input[placeholder*="Ask anything"]))
    end

    test "shows errors if the question is missing or is not meeting the required length", %{
      conn: conn
    } do
      {:ok, view, _html} = live(conn, "/")

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

    test "sending a message to the liveview changes its loading state", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")
      refute has_element?(view, ~s(div.animate-pulse))
      send(view.pid, {:loading_state, true})
      assert has_element?(view, ~s(div.animate-pulse))
    end

    test "page does not load on invalid data submission", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      view
      |> form("#question-input-form", user_question: %{query: ""})
      |> render_submit()

      refute has_element?(view, ~s(div.animate-pulse))
    end

    test "redirects to the question when episodes are found in the RAG process", %{
      conn: conn,
      embedding: embedding,
      episode: episode,
      response: response
    } do
      {:ok, view, _html} = live(conn, "/")

      _transcription = transcription_fixture(%{podcast_episode_id: episode.id})

      expect(Rag.MockEmbedder, :generate, 2, fn _question_episodes ->
        {:ok, [embedding]}
      end)

      expect(Rag.MockGenerator, :predict, fn _messages ->
        {:ok, response}
      end)

      view
      |> form("#question-input-form", user_question: %{query: "American Ponzi with Lee Camp"})
      |> render_submit()

      {path, _flash} = assert_redirect(view)
      assert path =~ ~r|/questions/|
    end

    test "renders an error message when the RAG process fails", %{
      conn: conn,
      episode: episode
    } do
      {:ok, view, _html} = live(conn, "/")

      _transcription = transcription_fixture(%{podcast_episode_id: episode.id})

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
    test "renders an error message when question creation fails", %{
      conn: conn,
      embedding: embedding,
      episode: episode,
      response: response
    } do
      {:ok, view, _html} = live(conn, "/")

      _transcription = transcription_fixture(%{podcast_episode_id: episode.id})

      expect(Rag.MockEmbedder, :generate, fn _question_episodes ->
        {:ok, [embedding]}
      end)

      expect(Rag.MockEmbedder, :generate, fn _question_episodes ->
        {:error, "failed to generate embeddings for the question"}
      end)

      expect(Rag.MockGenerator, :predict, fn _messages ->
        {:ok, response}
      end)

      view
      |> form("#question-input-form", user_question: %{query: "American Ponzi with Lee Camp"})
      |> render_submit()

      with_retries(
        fn ->
          assert render(view) =~ "There was an error processing your prompt"
        end,
        2
      )
    end

    @tag :capture_log
    test "shows an error message when the RAG process crashes", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

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
