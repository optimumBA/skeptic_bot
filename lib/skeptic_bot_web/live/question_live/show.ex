defmodule SkepticBotWeb.QuestionLive.Show do
  use SkepticBotWeb, :live_view

  alias SkepticBot.Prompts
  alias SkepticBotWeb.PodcastComponents

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div>
      <section class="relative max-w-[33.6rem] mx-auto mt-16 mb-10">
        <p class="text-[#000000] text-[3.75rem] leading-none montserrat-alternates-bold">
          <%= @query %>
        </p>
        <div class="absolute top-[-2.1rem] left-[-2.8rem]">
          <img src={~p"/images/home/top_letter.svg"} alt="Superscript Image Question" />
        </div>
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
                <PodcastComponents.related_episode_card
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
              disabled={@related_episodes_index >= length(@related_episodes) - 1}
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

        <section class="ml-5 mt-4 montserrat-alternates-bold text-[#000000] text-2xl">
          Other Podcasts
        </section>

        <section class="relative pb-16">
          <section class="ml-5 overflow-hidden pt-12 relative mb-12">
            <div
              class="flex gap-4 transition-transform duration-300 ease-in-out"
              style={"transform: translateX(-#{@other_episodes_index * 23.9}rem);"}
            >
              <%= for episode <- @other_episodes do %>
                <PodcastComponents.other_episode_card
                  external_id={episode.external_id}
                  podcast_title={episode.title}
                  random={
                    Enum.at(
                      @vector_numbers,
                      Enum.find_index(@other_episodes, fn x -> x == episode end)
                    )
                  }
                  thumbnail={episode.thumbnail}
                  video_length={episode.episode_length}
                />
              <% end %>
            </div>
          </section>
          <div class="ml-5 flex gap-5">
            <button
              phx-click="prev_other_episodes"
              class="disabled:opacity-50"
              disabled={@other_episodes_index == 0}
            >
              <div>
                <img src={~p"/images/podcasts/back_arrow.svg"} alt="Back Arrow" />
              </div>
            </button>
            <button
              phx-click="next_other_episodes"
              class="disabled:opacity-50"
              disabled={@other_episodes_index >= length(@other_episodes) - 1}
            >
              <div>
                <img src={~p"/images/podcasts/forward_arrow.svg"} alt="Forward Arrow" />
              </div>
            </button>
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
     |> assign(:other_episodes_index, 0)
     |> assign(:related_episodes_index, 0)
     |> assign(:vector_numbers, Enum.shuffle([1, 2, 3, 4, 5]))}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"id" => id}, _uri, socket) do
    question = Prompts.get_question!(id)

    related_episodes =
      Prompts.get_question_episodes(question.episodes)

    [most_related_episode | _other_related_episodes] = related_episodes

    other_episodes =
      Prompts.get_other_podcast_episodes(most_related_episode.embedding)

    {:noreply,
     socket
     |> assign(:query, question.query)
     |> assign(:other_episodes, other_episodes)
     |> assign(:related_episodes, related_episodes)}
  end

  @impl Phoenix.LiveView
  def handle_event("next_related_episodes", _params, socket) do
    index = socket.assigns.related_episodes_index
    new_index = min(index + 1, length(socket.assigns.related_episodes) - 1)
    {:noreply, assign(socket, :related_episodes_index, new_index)}
  end

  def handle_event("prev_related_episodes", _params, socket) do
    index = socket.assigns.related_episodes_index
    new_index = max(index - 1, 0)
    {:noreply, assign(socket, :related_episodes_index, new_index)}
  end

  def handle_event("next_other_episodes", _params, socket) do
    index = socket.assigns.other_episodes_index
    new_index = min(index + 1, length(socket.assigns.other_episodes) - 1)
    {:noreply, assign(socket, :other_episodes_index, new_index)}
  end

  def handle_event("prev_other_episodes", _params, socket) do
    index = socket.assigns.other_episodes_index
    new_index = max(index - 1, 0)
    {:noreply, assign(socket, :other_episodes_index, new_index)}
  end
end
