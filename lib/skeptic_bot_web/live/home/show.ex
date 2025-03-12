defmodule SkepticBotWeb.HomeLive.Show do
  @moduledoc """
  The Response Page.
  """

  use SkepticBotWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div>
        <%= live_render(@socket, SkepticBotWeb.Header,
          id: "live_header",
          sticky: true
        ) %>
      </div>
      <section class="relative max-w-[33.6rem] text-center mx-auto mb-10">
        <p class="text-[#000000] text-title leading-none montserrat-alternates-bold">
          Who Killed John F Kennedy
        </p>
        <div class="superscript-question-2">
          <img src={~p"/images/home/top_letter.svg"} alt="Superscript Image Question" />
        </div>
      </section>

      <section class="max-w-[34rem] mx-auto  montserrat-alternates-medium text-[#4D4D4D] mb-10">
        The assassination of John F. Kennedy has given rise to numerous conspiracy theories, several of which are prominently discussed
      </section>

      <section class="max-w-[90%] mx-auto  montserrat-alternates-bold text-[#000000] text-2xl">
        Top Podcast
      </section>

      <div class="flex justify-end">
        <section class="relative mb-32 w-[95%]">
          <div class="podcasts-grid">
            djddj
          </div>
        </section>
      </div>
    </div>
    """
  end

  # <img src={~p"/images/cards/scribble.svg"} alt="Scribble" class="scribble" />
  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => _id}, _url, socket) do
    # dbg(id)
    {:noreply, socket}
  end
end
