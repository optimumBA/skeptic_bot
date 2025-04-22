defmodule SkepticBotWeb.PodcastLive.Show do
  @moduledoc """
  Shows the results of a prompt i.e the related episodes.
  """

  use SkepticBotWeb, :live_view

  alias SkepticBotWeb.Prompt.Helpers

  alias SkepticBot.{Prompt, Podcasts}

  alias SkepticBotWeb.PodcastComponent

  alias SkepticBotWeb.Home.Component

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div>
      <div>
        <%= live_render(@socket, SkepticBotWeb.Header,
          id: "live_header",
          sticky: true
        ) %>
      </div>
      <section class="relative max-w-[33.6rem] mx-auto mb-10">
        <p class="text-[#000000] text-title leading-none montserrat-alternates-bold">
          <%= @query %>
        </p>
        <div class="absolute top-[-2.1rem] left-[-2.8rem]">
          <img src={~p"/images/home/top_letter.svg"} alt="Superscript Image Question" />
        </div>
      </section>

      <section class="max-w-[34rem] mx-auto  montserrat-alternates-medium text-[#4D4D4D] mb-10">
        <%= @result_description %>
      </section>

      <section class="max-w-[72.625rem] mx-auto  montserrat-alternates-bold text-[#000000] text-2xl">
        Related Podcasts
      </section>

      <section class="relative pb-16">
        <div class="flex justify-end ">
          <section class="overflow-hidden pt-12 relative mb-12 w-[93%] max-w-[83.625rem]">
            <div
              class="flex gap-4 transition-transform duration-300 ease-in-out"
              style={"transform: translateX(-#{@related_episodes_index * 20.6875}rem);"}
            >
              <%= for episode <- @related_episodes do %>
                <PodcastComponent.podcast_video_card
                  image_file={episode.thumbnail}
                  podcast_title={Helpers.first_n_words(episode.title, 2)}
                  video_length={episode.video_length}
                  random={round(1 + 4 * :rand.uniform())}
                />
              <% end %>
            </div>
          </section>
        </div>
        <div class="flex gap-5 max-w-[72.625rem] mx-auto mt-10">
          <button
            phx-click="prev_related_episodes"
            class="disabled:opacity-50"
            disabled={prev_btn_disabler(@related_episodes_index)}
          >
            <div>
              <img src={~p"/images/podcasts/back_arrow.svg"} alt="Back Arrow" />
            </div>
          </button>

          <button
            phx-click="next_related_episodes"
            class="disabled:opacity-50"
            disabled={
              forward_btn_disabler(
                @related_episodes_index,
                @related_episodes
              )
            }
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

      <section class="bg-[#FFF5F5] pt-28 pb-16">
        <section class="max-w-[72.625rem] mx-auto pb-10 montserrat-alternates-bold text-[#000000] text-2xl">
          Related Questions
        </section>
        <section class="max-w-[72.625rem] mx-auto">
          <section>
            <div class="grid grid-cols-3 gap-[1.125rem]">
              <%= for {question, number_on_list} <- @related_questions do %>
                <Component.episode_card
                  title={question.title}
                  body={Helpers.first_n_words(question.description, 40)}
                  people_count="134"
                  number={number_on_list}
                />
              <% end %>
            </div>
          </section>
        </section>
      </section>

      <section class="bg-[#ECF5FF] pt-28 pb-36">
        <section class="max-w-[72.625rem] mx-auto pb-10 montserrat-alternates-bold text-[#000000] text-2xl">
          Other Podcasts
        </section>

        <section class="max-w-[72.625rem] mx-auto">
          <div class="grid grid-cols-3 gap-[1.3125rem] max-w-[72rem]">
            <%= for episode <- @other_episodes do %>
              <PodcastComponent.podcast_video_grid_card
                image_file={episode.thumbnail}
                podcast_title={Helpers.first_n_words(episode.title, 2)}
                video_length={episode.video_length}
                random={round(1 + 2 * :rand.uniform())}
              />
            <% end %>
          </div>
        </section>
      </section>

      <Component.twitter_component />
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    other_episodes =
      Podcasts.get_first_six_records()
      |> Helpers.format_episodes()

    {:ok,
     socket
     |> assign(other_episodes: other_episodes)
     |> assign(other_episodes_index: 0)
     |> assign(related_episodes_index: 0)}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"id" => id}, _, socket) do
    question = Prompt.get_question!(id)

    related_questions =
      Helpers.get_related_questions(question.embedding, question.id)
      |> Helpers.return_question_and_number()

    list_of_episodes = Helpers.get_episodes(question.episodes)

    related_episodes = Helpers.format_episodes(list_of_episodes)

    {:noreply,
     socket
     |> assign(result_description: Helpers.format_description(question.description))
     |> assign(query: question.query)
     |> assign(related_episodes: related_episodes)
     |> assign(related_questions: related_questions)}
  end

  @impl Phoenix.LiveView
  def handle_event("next_related_episodes", _params, socket) do
    index = socket.assigns.related_episodes_index
    episodes = socket.assigns.related_episodes
    new_index = min(index + 1, length(episodes) - 1)
    {:noreply, assign(socket, related_episodes_index: new_index)}
  end

  def handle_event("prev_related_episodes", _params, socket) do
    index = socket.assigns.related_episodes_index
    new_index = max(index - 1, 0)
    {:noreply, assign(socket, related_episodes_index: new_index)}
  end

  def prev_btn_disabler(index) do
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

  # defp trim_description(description) do
  #   description =
  #     description
  #     |> String.split(".")
  #     |> Enum.take(1)

  #   description
  # end
end
