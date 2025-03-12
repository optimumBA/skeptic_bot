defmodule SkepticBotWeb.Header do
  @moduledoc """
  Renders the header as a child liveview inside
  every page
  """
  use SkepticBotWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket, layout: false}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-between py-8 text-[#000000] montserrat-alternates-bold">
      <section class="ml-20 text-[2rem]">Logo</section>

      <.link>
        <section class="mr-20 border-2 border-[#000000] rounded-lg px-6 py-3 text-sm">
          RECENT EPISODES
        </section>
      </.link>
    </div>
    """
  end
end
