defmodule SkepticBotWeb.PodcastLive.Show do
  @moduledoc """
  Shows the results of a prompt i.e the related episodes.
  """

  use SkepticBotWeb, :live_view

  import Ecto.Query
  import Pgvector.Ecto.Query, only: [l2_distance: 2]

  alias SkepticBot.{Prompt, Podcasts, Repo, Podcasts.Episode}

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
                  podcast_title={first_two_words(episode.title)}
                  video_length={episode.video_length}
                  random={:rand.uniform(5)}
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
                  body={question.description}
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
                podcast_title={first_two_words(episode.title)}
                video_length={episode.video_length}
                random={:rand.uniform(3)}
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
      |> format_episodes()

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
      get_related_questions(question.embedding, question.id)
      |> return_question_and_number()

    dbg(related_questions)

    list_of_episodes = get_episodes(question.episodes)

    related_episodes = format_episodes(list_of_episodes)

    {:noreply,
     socket
     |> assign(result_description: format_description(question.description))
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

  def format_episodes(episodes_list) do
    items =
      Enum.reduce(episodes_list, [], fn episode, output_list ->
        episode =
          case is_struct(episode) do
            true ->
              episode = Map.from_struct(episode)

              episode

            false ->
              episode
          end

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

  defp first_two_words(string) do
    string
    |> String.split(~r/\s+/, trim: true)
    |> Enum.take(2)
    |> Enum.join(" ")
  end

  def get_episodes(list_of_ids) do
    episodes =
      Enum.reduce(list_of_ids, [], fn map, list ->
        episode = Repo.get!(Episode, map.episode_id)

        [episode | list]
      end)

    episodes
  end

  # defp trim_description(description) do
  #   description =
  #     description
  #     |> String.split(".")
  #     |> Enum.take(1)

  #   description
  # end

  def format_description(string) do
    list_of_strings =
      String.split(string, "\n")
      |> Enum.filter(fn x -> x != "" end)

    formatted_string =
      Enum.map(list_of_strings, fn x ->
        (String.trim(x, "*")
         |> String.trim()) <> " "
      end)
      |> Enum.join()

    formatted_string
  end

  def get_related_questions(embedding, id) do
    questions =
      from(e in SkepticBot.Prompt.Question,
        select: %{id: e.id, description: e.description, title: e.query},
        where: e.id != ^id,
        order_by: [asc: l2_distance(e.embedding, ^embedding)],
        limit: 6
      )
      |> Repo.all()

    questions
  end

  defp return_question_and_number(list) do
    Enum.with_index(list, fn element, index -> {element, index + 1} end)
  end
end
