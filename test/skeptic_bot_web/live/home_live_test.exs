defmodule SkepticBotWeb.HomeLiveTest do
  use SkepticBotWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "/" do
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
  end
end
