defmodule SkepticBotWeb.HomeLive.EpisodesComponent do
  use SkepticBotWeb, :live_component

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

      <section class="relative pb-16">
        <div class="flex justify-end">
          <section class="overflow-hidden pt-12 relative mb-12 w-[95%]">
            <div
              class="flex gap-4 transition-transform duration-300 ease-in-out"
              style={"transform: translateX(-#{@index * 20.6875}rem);"}
            >
              <%= for item <- @items do %>
                <PodcastComponent.podcast_video_card
                  image_file={item.thumbnail}
                  podcast_title={item.title}
                  video_length={item.video_length}
                  random={:rand.uniform(5)}
                />
              <% end %>
            </div>
          </section>
        </div>

        <div class="flex gap-5 max-w-[90%] mx-auto mt-16">
          <button
            phx-click="prev"
            phx-target={@myself}
            class="disabled:opacity-50"
            disabled={prev_btn_disabler(@index)}
          >
            <div>
              <img src={~p"/images/podcasts/back_arrow.svg"} alt="Back Arrow" />
            </div>
          </button>

          <button
            phx-click="next"
            phx-target={@myself}
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

        <div class="podcast-scribble">
          <img src={~p"/images/podcasts/podcast_scribble.svg"} alt="Podcast Scribble" />
        </div>
      </section>
    </div>
    """
  end

  @impl true

  def update(assigns, socket) do
    %{list_of_episodes: list_of_episodes} = assigns

    {:ok,
     socket
     |> assign(assigns)
     |> assign(items: get_items(list_of_episodes))
     |> assign(index: 0)}
  end

  @impl true
  def handle_event("next", _, socket) do
    new_index = min(socket.assigns.index + 1, length(socket.assigns.items) - 1)
    {:noreply, assign(socket, index: new_index)}
  end

  @impl true
  def handle_event("prev", _, socket) do
    new_index = max(socket.assigns.index - 1, 0)
    {:noreply, assign(socket, index: new_index)}
  end

  def get_items(episodes_list) do
    items =
      Enum.reduce(episodes_list, [], fn episode, output_list ->
        episode = Map.from_struct(episode)

        episode = Map.put(episode, :thumbnail, "cover1.svg")
        episode = Map.put(episode, :video_length, "02:20:45")
        [episode | output_list]
      end)

    items
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
    # * called for the forward button
    if index >= length(items) - 1 do
      true
    else
      false
    end
  end
end

# [
#   %{
#     thumbnail: "cover1.svg",
#     podcast_title: "JFK Assassination",
#     video_length: "02:20:45"
#   },
#   %{
#     thumbnail: "cover2.svg",
#     podcast_title: "Space X",
#     video_length: "02:41:45"
#   },
#   %{
#     thumbnail: "cover3.svg",
#     podcast_title: "Trump's Rule",
#     video_length: "03:31:45"
#   },
#   %{
#     thumbnail: "cover4.svg",
#     podcast_title: "Kenya Chaos",
#     video_length: "04:31:45"
#   },
#   %{
#     thumbnail: "cover5.svg",
#     podcast_title: "Nigerian Delta",
#     video_length: "02:31:35"
#   },
#   %{
#     thumbnail: "cover1.svg",
#     podcast_title: "Women's Rights",
#     video_length: "02:53:45"
#   },
#   %{
#     thumbnail: "cover2.svg",
#     podcast_title: "USAID Crisis",
#     video_length: "10:36:45"
#   },
#   %{
#     thumbnail: "cover3.svg",
#     podcast_title: "Femicide",
#     video_length: "02:21:45"
#   }
# ]
