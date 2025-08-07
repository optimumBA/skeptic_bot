defmodule SkepticBotWeb.QuestionLive.Show do
  use SkepticBotWeb, :live_view

  alias SkepticBot.Prompts
  alias SkepticBotWeb.PodcastComponents

  @episode_limit 6
  @vector_numbers [1, 2, 3, 4, 5]
  @visible_episodes 3

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div>
      <section class="relative max-w-[33.6rem] mx-auto mt-16 mb-8 pl-4 sm:pl-0 border border-red-400">
        <p class="text-[#000000] text-[2rem] sm:text-[3.75rem] leading-[1.2] montserrat-alternates-bold">
          {@title}
        </p>
        <div class="hidden sm:block absolute top-[-2.1rem] left-[-2.8rem]">
          <img src={~p"/images/home/top_letter.svg"} alt="Superscript Image Question" />
        </div>
      </section>

      <section class="hidden max-w-[36.6rem] mx-auto mt-8 mb-10">
        <div
          id="typed-response"
          data-text={@description}
          phx-hook="Typewriter"
          phx-update="ignore"
          class="text-[#4D4D4D] leading-[1.6] montserrat-alternates-medium whitespace-pre-wrap"
        >
        </div>
      </section>

      <section
        class="mx-auto"
        style={"max-width: calc(" <> to_string(@visible_episodes) <>" * 20.8rem)"}
      >
        <section class="ml-5 montserrat-alternates-bold text-[#000000] text-2xl">
          Related Podcasts
        </section>
        <section class="relative pb-16">
          <section class="ml-5 overflow-hidden pt-12 relative mb-10">
            <div
              class="flex gap-4 transition-transform duration-300 ease-in-out"
              id="related-episodes-carousel"
              style={"transform: translateX(-#{@related_episodes_index * 20.6875}rem);"}
            >
              <%= for episode <- @related_episodes do %>
                <PodcastComponents.episode_card
                  external_id={episode.external_id}
                  podcast_title={episode.title}
                  random={
                    Enum.at(
                      @related_episodes_vectors,
                      Enum.find_index(@related_episodes, fn x -> x == episode end)
                    )
                  }
                  thumbnail={episode.thumbnail}
                  timestamp={if episode.timestamp, do: to_string(episode.timestamp.secs), else: "0"}
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
              phx-click={JS.push("next_related_episodes", value: %{batch_size: @mobile_batch_size})}
              class="md:hidden disabled:opacity-50"
              disabled={@has_all_related_episodes?}
            >
              <div>
                <img src={~p"/images/podcasts/forward_arrow.svg"} alt="Forward Arrow" />
              </div>
            </button>

            <button
              phx-click={JS.push("next_related_episodes", value: %{batch_size: @tablet_batch_size})}
              class="hidden md:block lg:hidden disabled:opacity-50"
              disabled={@has_all_related_episodes?}
            >
              <div>
                <img src={~p"/images/podcasts/forward_arrow.svg"} alt="Forward Arrow" />
              </div>
            </button>

            <button
              phx-click={JS.push("next_related_episodes", value: %{batch_size: @desktop_batch_size})}
              class="hidden lg:block disabled:opacity-50"
              disabled={@has_all_related_episodes?}
            >
              <div>
                <img src={~p"/images/podcasts/forward_arrow.svg"} alt="Forward Arrow" />
              </div>
            </button>
          </div>
        </section>

        <section class="ml-5 mt-4 montserrat-alternates-bold text-[#000000] text-2xl">
          Other Podcasts
        </section>

        <section class="relative pb-16">
          <section class="ml-5 overflow-hidden pt-12 relative mb-12">
            <div
              class="flex gap-4 transition-transform duration-300 ease-in-out"
              id="other-episodes-carousel"
              style={"transform: translateX(-#{@other_episodes_index * 20.6875}rem);"}
            >
              <%= for episode <- @other_episodes do %>
                <PodcastComponents.episode_card
                  external_id={episode.external_id}
                  podcast_title={episode.title}
                  random={
                    Enum.at(
                      @other_episodes_vectors,
                      Enum.find_index(@other_episodes, fn x -> x == episode end)
                    )
                  }
                  thumbnail={episode.thumbnail}
                  timestamp="0"
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
              disabled={@has_all_other_episodes?}
            >
              <div>
                <img src={~p"/images/podcasts/forward_arrow.svg"} alt="Forward Arrow" />
              </div>
            </button>
          </div>
        </section>
      </section>

      <section class="bg-[#FFF5F5] pt-20 pb-16">
        <section
          class="mx-auto"
          style={"max-width: calc(" <> to_string(@visible_episodes) <>" * 20.8rem)"}
        >
          <section class="ml-5 mb-10 montserrat-alternates-bold text-[#000000] text-2xl">
            Related Questions
          </section>
          <div class="ml-5 grid grid-cols-2 items-stretch gap-[2rem] lg:grid-cols-3 lg:gap-[1.2rem]">
            <%= for {question, question_index} <- @related_questions do %>
              <PodcastComponents.related_question_card
                description={question.description}
                question_id={question.id}
                question_index={question_index}
                title={question.title}
              />
            <% end %>
          </div>
        </section>
      </section>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    related_episodes_vectors =
      @vector_numbers
      |> Enum.shuffle()
      |> Stream.cycle()
      |> Enum.take(@episode_limit)

    other_episodes_vectors = Enum.shuffle(related_episodes_vectors)

    {:ok,
     socket
     |> assign(:desktop_batch_size, 3)
     |> assign(:mobile_batch_size, 1)
     |> assign(:other_episodes_index, 0)
     |> assign(:other_episodes_vectors, other_episodes_vectors)
     |> assign(:related_episodes_index, 0)
     |> assign(:related_episodes_vectors, related_episodes_vectors)
     |> assign(:tablet_batch_size, 2)
     |> assign(:visible_episodes, @visible_episodes)}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"id" => id}, _uri, socket) do
    question = Prompts.get_question(id)

    related_episodes =
      Prompts.get_related_episodes(question.episodes, question.embedding, @episode_limit)

    related_episode_count = Enum.count(related_episodes)

    [most_related_episode | _other_related_episodes] = related_episodes

    other_episodes =
      Prompts.get_other_episodes(most_related_episode.embedding, @episode_limit)

    other_episode_count = Enum.count(other_episodes)

    related_questions =
      question.embedding
      |> Prompts.get_related_questions(question.id)
      |> Enum.with_index()

    {:noreply,
     socket
     |> assign(:description, question.description)
     |> assign(:has_all_other_episodes?, has_all_episodes?(0, other_episode_count, 3))
     |> assign(:has_all_related_episodes?, has_all_episodes?(0, related_episode_count, 3))
     |> assign(:other_episodes, other_episodes)
     |> assign(:other_episode_count, other_episode_count)
     |> assign(:page_title, question.title)
     |> assign(:related_episodes, related_episodes)
     |> assign(:related_episode_count, related_episode_count)
     |> assign(:related_questions, related_questions)
     |> assign(:title, question.title)
     |> assign_seo_attributes(question, most_related_episode)}
  end

  @impl Phoenix.LiveView
  def handle_event("next_related_episodes", %{"batch_size" => batch_size} = _params, socket) do
    current_index = socket.assigns.related_episodes_index + 1
    episode_count = socket.assigns.related_episode_count

    {:noreply,
     socket
     |> assign(
       :has_all_related_episodes?,
       has_all_episodes?(current_index, episode_count, batch_size)
     )
     |> assign(
       :batch_size,
       batch_size
     )
     |> assign(:related_episodes_index, current_index)}
  end

  def handle_event("prev_related_episodes", _params, socket) do
    current_index = socket.assigns.related_episodes_index - 1
    episode_count = socket.assigns.related_episode_count
    batch_size = socket.assigns.batch_size

    {:noreply,
     socket
     |> assign(
       :has_all_related_episodes?,
       has_all_episodes?(current_index, episode_count, batch_size)
     )
     |> assign(:related_episodes_index, current_index)}
  end

  def handle_event("next_other_episodes", %{"batch_size" => batch_size} = _params, socket) do
    current_index = socket.assigns.other_episodes_index + 1
    episode_count = socket.assigns.other_episode_count

    {:noreply,
     socket
     |> assign(
       :has_all_other_episodes?,
       has_all_episodes?(current_index, episode_count, batch_size)
     )
     |> assign(:other_episodes_index, current_index)}
  end

  def handle_event("prev_other_episodes", %{"batch_size" => batch_size} = _params, socket) do
    current_index = socket.assigns.other_episodes_index - 1
    episode_count = socket.assigns.other_episode_count

    {:noreply,
     socket
     |> assign(
       :has_all_other_episodes?,
       has_all_episodes?(current_index, episode_count, batch_size)
     )
     |> assign(:other_episodes_index, current_index)}
  end

  defp has_all_episodes?(_current_index, episode_count, batch_size)
       when episode_count <= batch_size,
       do: true

  defp has_all_episodes?(current_index, episode_count, batch_size),
    do: current_index == episode_count - batch_size

  defp assign_seo_attributes(socket, question, episode) do
    attributes = %{
      description: question.description,
      image_url: get_image_url(episode),
      type: "article",
      url: url(~p"/questions/#{question.id}")
    }

    assign(socket, :seo_attributes, attributes)
  end

  defp get_image_url(episode) do
    "https://vid.samtripoli.com/" <> episode.thumbnail
  end
end
