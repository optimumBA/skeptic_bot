defmodule SkepticBotWeb.HomeLiveTest do
  use SkepticBotWeb.ConnCase, async: true

  import Mox
  import Phoenix.LiveViewTest
  import SkepticBot.PodcastsFixtures

  alias SkepticBot.Rag

  setup :verify_on_exit!

  defp create_prompt_resources_setup(%{conn: conn}) do
    embedding = embedding_fixture()
    episode = episode_fixture()
    response = response_fixture()

    %{
      conn: conn,
      embedding: embedding,
      episode: episode,
      response: response
    }
  end

  describe "/" do
    setup [:create_prompt_resources_setup]

    test "shows heading and subtitle", %{conn: conn} do
      {:ok, view, html} = live(conn, "/")
      assert html =~ "Skeptic."
      assert html =~ "bot"
      assert html =~ "Questions everything"

      assert has_element?(view, ~s(input[placeholder*="Ask anything"]))
    end

    test "shows errors if prompt is missing or is not meeting the required length", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      assert view
             |> form("#prompt-input-form", prompt: %{query: ""})
             |> render_change() =~ "can&#39;t be blank"

      assert view
             |> form("#prompt-input-form", prompt: %{query: "de"})
             |> render_change() =~ "Your prompt must be at least 4 characters in length"

      refute view
             |> form("#prompt-input-form", prompt: %{query: "Who killed Two Pac Shakur"})
             |> render_change() =~ "Your prompt must be at least 4 characters in length"
    end

    test "page does not load on invalid data submission", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")
      assert has_element?(view, ~s(div.h-screen.flex.items-center.relative))

      view
      |> form("#prompt-input-form", prompt: %{query: ""})
      |> render_submit()

      refute has_element?(view, ~s(div.animate-pulse))
    end

    test "redirects to the question when episodes are found", %{
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
      |> form("#prompt-input-form", prompt: %{query: "American Ponzi with Lee Camp"})
      |> render_submit()

      assert_redirect(view)
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
      |> form("#prompt-input-form", prompt: %{query: "American Ponzi with Lee Camp"})
      |> render_submit()

      assert render(view) =~
               "An error occurred while processing your prompt. Please try again."
    end

    test "renders an error message if question creation fails", %{
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

      expect(Rag.MockEmbedder, :generate, fn _question_episodes ->
        {:error, "failed to generate embeddings for the question"}
      end)

      view
      |> form("#prompt-input-form", prompt: %{query: "American Ponzi with Lee Camp"})
      |> render_submit()

      assert render(view) =~
               "There was an error processing your prompt"
    end
  end
end
