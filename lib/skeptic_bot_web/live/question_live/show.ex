defmodule SkepticBotWeb.QuestionLive.Show do
  use SkepticBotWeb, :live_view

  alias SkepticBot.Prompts
  alias SkepticBot.Prompts.QuestionsBroadcast
  alias SkepticBot.Prompts.UserQuestion
  alias SkepticBotWeb.HomeLive
  alias SkepticBotWeb.PodcastComponents

  @episode_limit 6
  @vector_numbers [1, 2, 3, 4, 5]
  @visible_episodes 3

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div id="question-live">
        <div
          class="mx-auto mt-16 px-5 mb-6 flex flex-col gap-10 md:gap-14"
          style={"max-width: calc(" <> to_string(@visible_episodes) <>" * 24.8rem)"}
        >
          <section class="w-max flex gap-4 items-center cursor-pointer" phx-click={JS.navigate("/")}>
            <div><img src={~p"/images/home/back_icon.svg"} alt="Superscript Image Question" /></div>
            <div class="text-custom-black montserrat-alternates-semibold">Back to homepage</div>
          </section>

          <section class={[
            "relative mx-auto md:max-w-[90%]",
            !@title && "hidden"
          ]}>
            <p class="text-[2rem] sm:text-[3.75rem] leading-[1.2] montserrat-alternates-bold 2sm:text-center">
              {@title}
            </p>

            <div class="hidden absolute top-[-2.1rem] left-[-0.8rem] md:block">
              <img src={~p"/images/home/top_letter.svg"} alt="Superscript Image Question" />
            </div>
          </section>
        </div>

        <section
          class="px-5 mx-auto mt-6 mb-10"
          style={"max-width: calc(" <> to_string(@visible_episodes) <>" * 21.8rem)"}
        >
          <p class="text-secondary leading-8 lg:text-center">
            {@description}
          </p>
          <div
            id="loading-elements"
            class={[
              "my-20",
              !@loading && "hidden"
            ]}
          >
            <HomeLive.Components.loading_component />
          </div>
        </section>

        <section
          class="mx-auto"
          style={"max-width: calc(" <> to_string(@visible_episodes) <>" * 24.8rem)"}
        >
          <section class="ml-5 montserrat-alternates-bold text-2xl">
            Related Podcasts
          </section>
          <section class="pb-6 relative">
            <section class="ml-5 mb-12 pt-12 pr-2 relative">
              <div class="flex gap-4 mobile-scroll-parent" id="related-episodes-carousel">
                <%= for episode <- @related_episodes do %>
                  <PodcastComponents.episode_card
                    episode={episode}
                    random={
                      Enum.at(
                        @related_episodes_vectors,
                        Enum.find_index(@related_episodes, fn x -> x == episode end)
                      )
                    }
                    timestamp={if episode.timestamp, do: to_string(episode.timestamp.secs), else: "0"}
                  />
                <% end %>
              </div>
            </section>
          </section>

          <section class="ml-5 mt-2 montserrat-alternates-bold text-2xl">
            Other Podcasts
          </section>

          <section class="pb-16 relative">
            <section class="ml-5 mb-12 pr-2 pt-12 relative">
              <div class="flex gap-4 mobile-scroll-parent" id="other-episodes-carousel">
                <%= for episode <- @other_episodes do %>
                  <PodcastComponents.episode_card
                    episode={episode}
                    random={
                      Enum.at(
                        @other_episodes_vectors,
                        Enum.find_index(@other_episodes, fn x -> x == episode end)
                      )
                    }
                    timestamp="0"
                  />
                <% end %>
              </div>
            </section>
          </section>
        </section>

        <section class="bg-[#FFF5F5] pt-20 pb-16">
          <section
            class="mx-auto"
            style={"max-width: calc(" <> to_string(@visible_episodes) <>" * 24.8rem)"}
          >
            <section class="ml-5 mb-10 montserrat-alternates-bold text-2xl">
              Related Questions
            </section>
            <div class="mx-5 grid grid-cols-1 items-stretch gap-[2rem] md:grid-cols-2 lg:grid-cols-3 lg:gap-[1.2rem]">
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
    </Layouts.app>
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
     |> assign(:other_episodes_vectors, other_episodes_vectors)
     |> assign(:related_episodes_vectors, related_episodes_vectors)
     |> assign(:visible_episodes, @visible_episodes)}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"id" => id}, _uri, socket) do
    question = Prompts.get_question(id)
    if connected?(socket), do: QuestionsBroadcast.subscribe(question.id)

    related_episodes =
      Prompts.get_related_episodes(question.episodes, question.embedding, @episode_limit)

    [most_related_episode | _other_related_episodes] = related_episodes

    other_episodes =
      Prompts.get_other_episodes(most_related_episode.embedding, @episode_limit)

    related_questions =
      question.embedding
      |> Prompts.get_related_questions(question.id)
      |> Enum.with_index()

    {:noreply,
     socket
     |> assign(:description, question.description)
     |> assign(:other_episodes, other_episodes)
     |> assign(:page_title, question.title)
     |> assign(:question, question)
     |> assign(:related_episodes, related_episodes)
     |> assign(:related_questions, related_questions)
     |> assign(:title, question.title)
     |> assign_loading_state(question)
     |> assign_seo_attributes(question, most_related_episode)}
  end

  defp assign_loading_state(socket, %UserQuestion{title: nil} = _question),
    do: assign(socket, :loading, true)

  defp assign_loading_state(socket, _question),
    do: assign(socket, :loading, false)

  defp assign_seo_attributes(socket, question, episode) do
    attributes = %{
      description: question.description,
      image_url: get_image_url(episode),
      type: "article",
      url: url(~p"/questions/#{question.id}")
    }

    assign(socket, :seo_attributes, attributes)
  end

  @impl Phoenix.LiveView
  def handle_info({:prediction_result, {title, description}}, socket) do
    {:noreply,
     socket
     |> assign(:description, description)
     |> assign(:title, title)}
  end

  def handle_info({:prediction_complete, {title, description}}, socket) do
    {:noreply,
     socket
     |> assign(:description, description)
     |> assign(:loading, false)
     |> assign(:title, title)}
  end

  defp get_image_url(episode) do
    episode.thumbnail
  end
end
