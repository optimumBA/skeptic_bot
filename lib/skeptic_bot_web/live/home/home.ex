defmodule SkepticBotWeb.HomeLive.Index do
  @moduledoc """
  The home page containing the chat input.
  """

  use SkepticBotWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%= live_render(@socket, SkepticBotWeb.Header,
        id: "live_header",
        sticky: true
      ) %>

      <div class="flex justify-start items-center">
        <section class="">
          <img src={~p"/images/home/top_swirl.svg"} alt="Swirl" />
        </section>
        <section class="flex flex-col">
          <section>Your Daily <span>Podcast</span></section>

          <section>Ask anything and get answers directly from trusted experts</section>

          <section>
            <.live_component module={SkepticBotWeb.HomeLive.FormComponent} id="prompt form" />
          </section>
        </section>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
