defmodule SkepticBotWeb.HomeLiveTest do
  use SkepticBotWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  describe "/" do
    test "check homepage content on mount connection", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")

      assert html =~ "Skeptic."
      assert html =~ "Bot"

      assert html =~ "Questions everything"
    end
  end
end
