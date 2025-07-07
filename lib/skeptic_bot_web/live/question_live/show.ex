defmodule SkepticBotWeb.QuestionLive.Show do
  use SkepticBotWeb, :live_view

  alias SkepticBot.Prompts
  alias SkepticBotWeb.PodcastComponents

  @episode_batch_size 3
  @episode_limit 6

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div>
      <section class="relative max-w-[33.6rem] mx-auto mt-16 mb-8">
        <p class="text-[#000000] text-[3.75rem] leading-[1.2] montserrat-alternates-bold">
          <%= @question.query %>
        </p>
        <div class="absolute top-[-2.1rem] left-[-2.8rem]">
          <img src={~p"/images/home/top_letter.svg"} alt="Superscript Image Question" />
        </div>
      </section>

      <section class="max-w-[36.6rem] mx-auto mt-8 mb-10">
        <p class="text-[#4D4D4D] leading-[1.6] montserrat-alternates-medium">
          <%= PodcastComponents.first_n_words(@question.description, 40) %>...
        </p>
      </section>

      <section class="max-w-[75.0625rem] mx-auto">
        <section class="ml-5 montserrat-alternates-bold text-[#000000] text-2xl">
          Related Podcasts
        </section>
        <section class="relative pb-16">
          <section class="ml-5 overflow-hidden pt-12 relative mb-12">
            <div
              id="stream_related_episodes"
              phx-update="stream"
              class="flex gap-4 transition-transform duration-300 ease-in-out"
              style={"transform: translateX(-#{@related_episodes_index * 20.6875}rem);"}
            >
              <%= for {id, episode} <- @streams.related_episodes do %>
                <PodcastComponents.episode_card
                  dom_id={id}
                  external_id={episode.external_id}
                  podcast_title={episode.title}
                  random={episode.random_number}
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
              disabled={@has_all_related_episodes?}
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
  def handle_params(%{"id" => id}, _uri, socket) do
    question = Prompts.get_question(id)

    related_episodes =
      question.episodes
      |> Prompts.get_related_episodes(question.embedding, @episode_batch_size, 0)
      |> add_random_num_to_episode(Enum.shuffle([1, 2, 3]))

    related_episodes_count =
      Prompts.count_related_episodes(question.embedding, @episode_limit)

    related_episodes_pages =
      ceil(related_episodes_count / @episode_batch_size)

    related_episodes_page = 1
    has_all_related_episodes? = related_episodes_page == related_episodes_pages

    {:noreply,
     socket
     |> assign(:has_all_related_episodes?, has_all_related_episodes?)
     |> assign(:question, question)
     |> stream(:related_episodes, related_episodes)
     |> assign(:related_episodes_index, 0)
     |> assign(:related_episodes_page, related_episodes_page)
     |> assign(:related_episodes_pages, related_episodes_pages)}
  end

  @impl Phoenix.LiveView
  def handle_event("next_related_episodes", _params, socket) do
    question = socket.assigns.question
    total_pages = socket.assigns.related_episodes_pages

    current_index = socket.assigns.related_episodes_index
    new_index = current_index + 1

    current_page = socket.assigns.related_episodes_page
    new_page = get_new_episode_page(total_pages, current_page, new_index)

    related_episodes =
      get_new_related_episodes(new_page, current_page, question, 3, Enum.shuffle([4, 5, 2]))

    has_all_related_episodes? = has_all_episodes?(new_index, total_pages)

    {:noreply,
     socket
     |> assign(:has_all_related_episodes?, has_all_related_episodes?)
     |> stream(:related_episodes, related_episodes)
     |> assign(:related_episodes_page, new_page)
     |> assign(:related_episodes_index, new_index)}
  end

  def handle_event("prev_related_episodes", _params, socket) do
    index = socket.assigns.related_episodes_index
    new_index = index - 1
    total_pages = socket.assigns.related_episodes_pages

    has_all_related_episodes? = has_all_episodes?(new_index, total_pages)

    {:noreply,
     socket
     |> assign(:has_all_related_episodes?, has_all_related_episodes?)
     |> assign(:related_episodes_index, new_index)}
  end

  defp has_all_episodes?(index, total_pages), do: index == total_pages * @episode_batch_size - 3

  defp get_new_episode_page(total_pages, current_page, _new_index)
       when total_pages == current_page,
       do: current_page

  defp get_new_episode_page(_total_pages, current_page, new_index) do
    get_page(current_page, new_index, @episode_batch_size)
  end

  defp get_page(page, index, batch_size) do
    if rem(index, batch_size) == 1 do
      page + 1
    else
      page
    end
  end

  defp add_random_num_to_episode(related_episodes, vector_numbers) do
    related_episodes
    |> Enum.with_index()
    |> Enum.map(fn {episode, index} ->
      Map.put(episode, :random_number, Enum.at(vector_numbers, index))
    end)
  end

  defp get_new_related_episodes(new_page, current_page, question, offset, new_vector_numbers)
       when new_page > current_page do
    question.episodes
    |> Prompts.get_related_episodes(
      question.embedding,
      @episode_batch_size,
      offset
    )
    |> add_random_num_to_episode(new_vector_numbers)
  end

  defp get_new_related_episodes(_new_page, _current_page, _question, _offset, _new_vector_numbers) do
    []
  end
end
