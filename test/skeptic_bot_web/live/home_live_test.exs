defmodule SkepticBotWeb.HomeLiveTest do
  use SkepticBotWeb.ConnCase, async: true

  import Mox
  import Phoenix.LiveViewTest
  import SkepticBot.EpisodesFixtures

  alias SkepticBot.Rag.EmbeddingMock
  alias SkepticBot.RagMock

  setup :verify_on_exit!

  defp create_episodes_setup(%{conn: conn}) do
    episode = episode_fixture()
    embedding = embedding_fixture()
    description = description_fixture()

    %{conn: conn, episode: episode, embedding: embedding, description: description}
  end

  describe "/" do
    setup [:create_episodes_setup]

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

      refute has_element?(view, ~s(div.h-screen.flex.items-center.relative.animate-pulse))
    end

    test "renders error message when no episodes are found", %{
      conn: conn,
      description: description
    } do
      expect(RagMock, :generate, fn _query ->
        {:ok, {description, []}}
      end)

      {:ok, view, _html} = live(conn, "/")

      view
      |> form("#prompt-input-form",
        prompt: %{query: "I have no idea that this will not return any episodes"}
      )
      |> render_submit()

      assert render(view) =~ "No related podcast was found"
      refute has_element?(view, ~s(div.h-screen.flex.items-center.relative.animate-pulse))
    end

    test "redirects when episodes are found", %{
      conn: conn,
      episode: episode,
      description: description,
      embedding: embedding
    } do
      expect(RagMock, :generate, fn _query ->
        {:ok, {description, [episode]}}
      end)

      expect(EmbeddingMock, :generate, fn _embedding_value ->
        {:ok, [embedding]}
      end)

      {:ok, view, _html} = live(conn, "/")

      view
      |> form("#prompt-input-form", prompt: %{query: "American Ponzi with Lee Camp"})
      |> render_submit()

      assert_redirect(view)
    end
  end
end
