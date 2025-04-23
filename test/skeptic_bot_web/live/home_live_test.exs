defmodule SkepticBotWeb.HomeLiveTest do
  use SkepticBotWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  describe "/" do
    test "check homepage content on mount connection", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "Logo"
      assert html =~ "RECENT EPISODES"

      assert html =~ "Your Daily"
      assert html =~ "Podcast"

      assert html =~ "Ask anything and get answers directly from trusted experts"
      assert html =~ "Popular Podcast"
    end
  end
end
