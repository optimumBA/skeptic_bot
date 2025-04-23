defmodule SkepticBotWeb.HeaderLive do
  @moduledoc """
  Renders the header as a child liveview inside
  every page
  """
  use SkepticBotWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket, layout: false}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="w-[86%] max-w-[72.625rem] mx-auto flex items-center justify-between py-8 text-[#000000] montserrat-alternates-bold z-30">
      <.link navigate={~p"/"}>
        <section class="text-[2rem]">Logo</section>
      </.link>

      <.link navigate={~p"/"}>
        <section class="border-2 border-[#000000] rounded-lg px-6 py-3 text-sm">
          RECENT EPISODES
        </section>
      </.link>
    </div>
    """
  end
end
