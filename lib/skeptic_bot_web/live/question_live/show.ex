defmodule SkepticBotWeb.QuestionLive.Show do
  use SkepticBotWeb, :live_view

  alias SkepticBot.Prompts
  alias SkepticBotWeb.PodcastComponents

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div>
      <section class="relative max-w-[33.6rem] mx-auto mt-16 mb-8">
        <p class="text-[#000000] text-[3.75rem] leading-[1.2] montserrat-alternates-bold">
          <%= @query %>
        </p>
        <div class="absolute top-[-2.1rem] left-[-2.8rem]">
          <img src={~p"/images/home/top_letter.svg"} alt="Superscript Image Question" />
        </div>
      </section>

      <section class="max-w-[36.6rem] mx-auto mt-8 mb-10">
        <p class="text-[#4D4D4D] leading-[1.6] montserrat-alternates-medium">
          <%= PodcastComponents.first_n_words(@description, 40) %>...
        </p>
      </section>

      <section class="max-w-[75.0625rem] mx-auto">
        <section class="ml-5 montserrat-alternates-bold text-[#000000] text-2xl">
          Related Podcasts
        </section>
        <section class="relative pb-16">
          <section class="ml-5 overflow-hidden pt-12 relative mb-12">
            <div
              class="flex gap-4 transition-transform duration-300 ease-in-out"
              style={"transform: translateX(-#{@related_episodes_index * 20.6875}rem);"}
            >
              <%= for episode <- @related_episodes do %>
                <PodcastComponents.episode_card
                  external_id={episode.external_id}
                  podcast_title={episode.title}
                  random={
                    Enum.at(
                      @vector_numbers,
                      Enum.find_index(@related_episodes, fn x -> x == episode end)
                    )
                  }
                  thumbnail={episode.thumbnail}
                  timestamp={to_string(episode.timestamp.secs)}
                  video_length={episode.episode_length}
                />
              <% end %>
            </div>
          </section>
          <div class="ml-5 flex gap-5">
            <button
              phx-click="prev_related_episodes"
              class="disabled:opacity-50"
              disabled={@related_episodes_index == 0}
            >
              <div>
                <img src={~p"/images/podcasts/back_arrow.svg"} alt="Back Arrow" />
              </div>
            </button>
            <button
              phx-click="next_related_episodes"
              class="disabled:opacity-50"
              disabled={@has_all_related_episode_pages?}
            >
              <div>
                <img src={~p"/images/podcasts/forward_arrow.svg"} alt="Forward Arrow" />
              </div>
            </button>
          </div>
          <div class="absolute bottom-[-5rem] right-[5%]">
            <img src={~p"/images/podcasts/podcast_scribble.svg"} alt="Podcast Scribble" />
          </div>
        </section>
      </section>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:related_episodes_index, 0)
     |> assign(:vector_numbers, Enum.shuffle([1, 2, 3, 4, 5]))}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"id" => id}, _uri, socket) do
    question = Prompts.get_question(id)

    related_episodes =
      Prompts.get_related_episodes(question.episodes)

    has_all_related_episode_pages? = length(related_episodes) <= 3

    {:noreply,
     socket
     |> assign(:description, question.description)
     |> assign(:query, question.query)
     |> assign(:related_episodes, related_episodes)
     |> assign(:has_all_related_episode_pages?, has_all_related_episode_pages?)}
  end

  @impl Phoenix.LiveView
  def handle_event("next_related_episodes", _params, socket) do
    index = socket.assigns.related_episodes_index
    related_episodes = socket.assigns.related_episodes
    new_index = min(index + 1, length(related_episodes) - 1)
    has_all_related_episode_pages? = length(related_episodes) - new_index <= 3

    {:noreply,
     socket
     |> assign(:related_episodes_index, new_index)
     |> assign(:has_all_related_episode_pages?, has_all_related_episode_pages?)}
  end

  def handle_event("prev_related_episodes", _params, socket) do
    index = socket.assigns.related_episodes_index
    new_index = max(index - 1, 0)
    {:noreply, assign(socket, :related_episodes_index, new_index)}
  end
end
