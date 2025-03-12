defmodule SkepticBotWeb.HomeLive.Show do
  @moduledoc """
  The Response Page.
  """

  use SkepticBotWeb, :live_view

  alias SkepticBotWeb.PodcastComponent

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
        <section class="overflow-hidden relative mb-12 w-[95%]">
          <div
            class="flex gap-4 transition-transform duration-300"
            style={"transform: translateX(-#{@index * 315}px);"}
          >
            <%= for item <- @items do %>
              <PodcastComponent.podcast_video_card image_file={item.thumbnail} />
            <% end %>
          </div>
        </section>
      </div>

      <div class="flex gap-5 max-w-[90%] mx-auto">
        <button phx-click="prev" class="disabled:opacity-50" disabled={prev_btn_disabler(@index)}>
          <div>
            <img src={~p"/images/podcasts/back_arrow.svg"} alt="Back Arrow" />
          </div>
        </button>

        <button
          phx-click="next"
          class="disabled:opacity-50"
          disabled={
            forward_btn_disabler(
              @index,
              @items
            )
          }
        >
          <div>
            <img src={~p"/images/podcasts/forward_arrow.svg"} alt="Forward Arrow" />
          </div>
        </button>
      </div>
    </div>
    """
  end

  # <img src={~p"/images/cards/scribble.svg"} alt="Scribble" class="scribble" />
  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(items: get_items())
     |> assign(index: 0)}
  end

  @impl true
  def handle_params(%{"id" => _id}, _url, socket) do
    # dbg(id)
    {:noreply, socket}
  end

  def handle_event("next", _, socket) do
    dbg(socket.assigns.items)
    new_index = min(socket.assigns.index + 1, length(socket.assigns.items) - 1)
    {:noreply, assign(socket, index: new_index)}
  end

  def handle_event("prev", _, socket) do
    new_index = max(socket.assigns.index - 1, 0)
    {:noreply, assign(socket, index: new_index)}
  end

  def get_items() do
    [
      %{
        thumbnail: "cover2.svg"
      },
      %{
        thumbnail: "cover2.svg"
      },
      %{
        thumbnail: "cover2.svg"
      },
      %{
        thumbnail: "cover2.svg"
      },
      %{
        thumbnail: "cover2.svg"
      },
      %{
        thumbnail: "cover2.svg"
      },
      %{
        thumbnail: "cover2.svg"
      },
      %{
        thumbnail: "cover2.svg"
      },
      %{
        thumbnail: "cover2.svg"
      },
      %{
        thumbnail: "cover2.svg"
      }
    ]
  end

  def prev_btn_disabler(index) do
    # * called for the prev button
    if index == 0 do
      true
    else
      false
    end
  end

  def forward_btn_disabler(index, items) do
    if index >= length(items) - 1 do
      true
    else
      false
    end
  end
end
