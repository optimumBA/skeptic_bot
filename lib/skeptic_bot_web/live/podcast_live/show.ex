defmodule SkepticBotWeb.PodcastLive.Show do
  use SkepticBotWeb, :live_view

  alias SkepticBot.Prompts
  alias SkepticBotWeb.PodcastComponents

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div>
      <section class="relative max-w-[33.6rem] mx-auto mt-16 mb-10">
        <p class="text-[#000000] text-[3.75rem] leading-none montserrat-alternates-bold">
          {@query}
        </p>
        <div class="absolute top-[-2.1rem] left-[-2.8rem]">
          <img src={~p"/images/home/top_letter.svg"} alt="Superscript Image Question" />
        </div>
      </section>

      <section class="max-w-[72.625rem] mx-auto  montserrat-alternates-bold text-[#000000] text-2xl">
        <div class="ml-5">Related Podcasts</div>
      </section>

      <section class="relative pb-16">
        <div class="flex justify-end ">
          <section class="overflow-hidden pt-12 relative mb-12 w-[93%] max-w-[83.625rem]">
            <div
              class="flex gap-4 transition-transform duration-300 ease-in-out"
              style={"transform: translateX(-#{@related_episodes_index * 20.6875}rem);"}
            >
              <%= for episode <- @related_episodes do %>
                <PodcastComponents.podcast_video_card
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
        </div>
        <div class="flex gap-5 max-w-[72.625rem] mx-auto mt-10">
          <button
            phx-click="prev_related_episodes"
            class="disabled:opacity-50 ml-5"
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

        <div class="absolute bottom-[-5rem] right-[8rem]">
          <img src={~p"/images/podcasts/podcast_scribble.svg"} alt="Podcast Scribble" />
        </div>
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
    question = Prompts.get_question!(id)

    related_episodes =
      get_prompts_context().get_question_episodes(question.episodes)

    {:noreply,
     socket
     |> assign(:query, question.query)
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

  defp get_prompts_context do
    Application.get_env(:skeptic_bot, :prompts_context_module, SkepticBot.Prompts)
  end
end
