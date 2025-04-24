defmodule SkepticBotWeb.HomeLiveTest do
  use SkepticBotWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "/" do
    test "shows heading and subtitle", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")

      assert html =~ "Skeptic."
      assert html =~ "bot"

      assert html =~ "Questions everything"
    end
  end
end
