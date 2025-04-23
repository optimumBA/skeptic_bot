defmodule SkepticBotWeb.HomeLiveTest do
  use SkepticBotWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  describe "/" do
    test "check homepage content on mount connection", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")

      assert html =~ "SKEPTIC."
      assert html =~ "BOT"

      assert html =~ "Ask anything and get answers directly from trusted experts"
    end
  end
end
