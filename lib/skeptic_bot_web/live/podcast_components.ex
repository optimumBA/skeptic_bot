defmodule SkepticBotWeb.PodcastComponents do
  @moduledoc """
  Dead components concerned with rendering podcast related content
  """

  use SkepticBotWeb, :html

  require Integer

  @type assigns :: map()
  @type rendered :: Phoenix.LiveView.Rendered.t()

  @episode_url_rokfin "https://rokfin.com/post/"
  @episode_url_rumble "https://rumble.com/"
  @episode_url_tinfoilhat "https://vid.samtripoli.com/w/"
  @episode_url_youtube "https://www.youtube.com/watch?v="
  @podcast_brokensimulation "Broken Simulation"
  @podcast_candace "Candace"
  @podcast_cashdaddies "Cash Daddies"
  @podcast_deepwaters "Deep Waters"
  @podcast_doomscrollin "Doom Scrollin"
  @podcast_lookintoit "Look Into It"
  @podcast_nephilimdeathsquad "Nephilim Death Squad"
  @podcast_tinfoilhat "Tin Foil Hat"
  @podcast_unionoftheunwanted "Union of the Unwanted"
  @podcast_zerowithsamtripoli "Zero with Sam Tripoli"
  @samtripoliwebsite_podcasts [
    @podcast_cashdaddies,
    @podcast_doomscrollin,
    @podcast_tinfoilhat,
    @podcast_unionoftheunwanted,
    @podcast_zerowithsamtripoli
  ]
  @yt_podcasts [
    @podcast_brokensimulation,
    @podcast_candace,
    @podcast_deepwaters,
    @podcast_nephilimdeathsquad
  ]

  attr :episode_vectors, :list, required: true
  attr :episodes, :list, required: true
  attr :icon_path, :string, default: nil
  attr :title, :string, required: true

  @spec episode_card_carousel(assigns()) :: rendered()
  def episode_card_carousel(assigns) do
    ~H"""
    <section class="ml-5 montserrat-alternates-bold text-2xl flex items-center gap-2">
      <div class={[
        !@icon_path && "hidden"
      ]}>
        <img src={@icon_path} alt="title image" class="w-full h-full object-cover" />
      </div>
      <div>
        {@title}
      </div>
    </section>
    <section class="pb-4 relative">
      <section class="ml-5 mb-6 pt-8 pr-2 relative">
        <div class="flex gap-4 mobile-scroll-parent">
          <%= for episode <- @episodes do %>
            <.episode_card
              episode={episode}
              random={
                Enum.at(
                  @episode_vectors,
                  Enum.find_index(@episodes, fn x -> x == episode end)
                )
              }
              timestamp={if episode.timestamp, do: to_string(episode.timestamp.secs), else: "0"}
            />
          <% end %>
        </div>
      </section>
    </section>
    """
  end

  attr :episode, :map, required: true
  attr :random, :integer, required: true
  attr :timestamp, :string, required: true

  @spec episode_card(assigns()) :: rendered()
  def episode_card(assigns) do
    ~H"""
    <div class="flex flex-col gap-4 transition-[font-weight] duration-500 ease-in-out hover:font-[500]">
      <a href={episode_url(@episode.external_id, @timestamp, @episode.podcast.name)}>
        <section class="w-[19.6875rem] h-[19.6875rem] shrink-0 relative mobile-scroll-child 2sm:w-[24rem]">
          <div class="w-full h-full rounded-xl overflow-hidden zoom-in-episode">
            <img
              src={@episode.thumbnail}
              alt="Cover 2"
              class="w-full h-full object-cover"
            />
          </div>
          <div class="w-[19.6875rem] h-[8.2rem] absolute bottom-0 left-0 rounded-b-xl blur-episode 2sm:w-[24rem]">
          </div>

          {get_episode_vector(@random)}

          <div class="absolute bottom-[2.5rem] left-[1rem] text-xl montserrat-alternates-bold text-custom-white">
            {trim_title(@episode.title)}
          </div>
          <div class="absolute bottom-[1rem] left-[1.2rem] flex gap-2 montserrat-alternates-semibold text-custom-white">
            <div>
              <img src={~p"/images/podcasts/podcast_play.svg"} alt="Podcast Play Icon" />
            </div>
            <div class="text-sm">{get_time_from_seconds(@episode.episode_length)}</div>
          </div>
        </section>
      </a>

      <div class="w-[19.6875rem] shrink-0 text-sm leading-6 2sm:w-[24rem] 2sm:text-base">
        {@episode.teaser}
      </div>
    </div>
    """
  end

  attr :description, :string, required: true
  attr :question_id, :string, required: true
  attr :question_index, :integer, required: true
  attr :title, :string, required: true

  @spec related_question_card(assigns()) :: rendered()
  def related_question_card(assigns) do
    ~H"""
    <div
      class="bg-custom-white border-2 rounded-2xl cursor-pointer question-card-shadow"
      phx-click={JS.navigate(~p"/questions/#{@question_id}")}
    >
      <div class="flex flex-col px-3 pt-4 pb-2 text-secondary">
        <section class="flex justify-between items-center">
          <div class={[
            "text-2xl montserrat-alternates-bold",
            related_question_title_class(@question_index)
          ]}>
            {@title}
          </div>
          <div class="shrink-0 pr-4">
            <img src={~p"/images/podcasts/xmark.svg"} alt="X Mark" />
          </div>
        </section>
        <div class="divider"></div>
        <div class="text-sm w-[88%]">
          {trim_description(@description)}
        </div>
      </div>
    </div>
    """
  end

  defp absolute_vectors(%{random: 1} = assigns) do
    ~H"""
    <img
      src={~p"/images/vectors/podcast_vector1.svg"}
      alt="Podcast Vector 1"
      class="absolute bottom-[4rem] left-[3rem]"
    />

    <img
      src={~p"/images/vectors/podcast_vector2.svg"}
      alt="Podcast Vector 2"
      class="absolute top-[-3rem] left-[-0.8rem]"
    />

    <img
      src={~p"/images/vectors/vector3.svg"}
      alt="Vector 3"
      class="absolute top-[2.2rem] left-[9.7rem]"
    />
    <img
      src={~p"/images/vectors/vector2.svg"}
      alt="Vector 2"
      class="absolute bottom-[4rem] right-[2.8rem]"
    />
    """
  end

  defp absolute_vectors(%{random: 2} = assigns) do
    ~H"""
    <img
      src={~p"/images/vectors/star2.svg"}
      alt="Star 2"
      class="absolute bottom-[2.7rem] right-[6.7rem]"
    />
    <img
      src={~p"/images/vectors/vector5.svg"}
      alt="Vector 5"
      class="absolute top-[3rem] right-[9rem]"
    />

    <img
      src={~p"/images/vectors/vector4.svg"}
      alt="Vector 4"
      class="absolute top-[7.5rem] left-[7rem]"
    />
    """
  end

  defp absolute_vectors(%{random: 3} = assigns) do
    ~H"""
    <img
      src={~p"/images/vectors/vector7.svg"}
      alt="Vector 7"
      class="absolute top-[4.8rem] left-[6rem]"
    />
    """
  end

  defp absolute_vectors(%{random: 4} = assigns) do
    ~H"""
    <img src={~p"/images/vectors/vector8.svg"} alt="Vector 8" class="absolute top-0 left-0" />

    <img
      src={~p"/images/vectors/vector9.svg"}
      alt="Vector 9"
      class="absolute bottom-[6.2rem] left-[7.8rem]"
    />

    <img
      src={~p"/images/vectors/vector10.svg"}
      alt="Vector 10"
      class="absolute top-[7rem] left-[3.5rem]"
    />
    <img
      src={~p"/images/vectors/vector11.svg"}
      alt="Vector 11"
      class="absolute top-[7.8rem] left-[2.9rem]"
    />
    <img
      src={~p"/images/vectors/vector12.svg"}
      alt="Vector 12"
      class="absolute top-[4.9rem] right-[11.7rem]"
    />
    <img
      src={~p"/images/vectors/vector13.svg"}
      alt="Vector 13"
      class="absolute top-[6.8rem] right-[5.2rem]"
    />
    <img
      src={~p"/images/vectors/vector14.svg"}
      alt="Vector 14"
      class="absolute top-[9rem] right-[2.4rem]"
    />
    <img
      src={~p"/images/vectors/vector15.svg"}
      alt="Vector 15"
      class="absolute top-[8.5rem] right-[1.8rem]"
    />
    <img
      src={~p"/images/vectors/vector16.svg"}
      alt="Vector 16"
      class="absolute top-[8.75rem] right-[1.4rem]"
    />
    <img
      src={~p"/images/vectors/vector17.svg"}
      alt="Vector 17"
      class="absolute top-[9.1rem] right-[1.7rem]"
    />
    """
  end

  defp absolute_vectors(%{random: 5} = assigns) do
    ~H"""
    <img
      src={~p"/images/vectors/vector18.svg"}
      alt="Vector 18"
      class="absolute top-[7rem] left-[1.7rem]"
    />
    <img
      src={~p"/images/vectors/vector19.svg"}
      alt="Vector 19"
      class="absolute top-[7.8rem] left-[2.2rem]"
    />
    <img
      src={~p"/images/vectors/vector20.svg"}
      alt="Vector 20"
      class="absolute top-[8rem] left-[1.8rem]"
    />
    <img
      src={~p"/images/vectors/vector21.svg"}
      alt="Vector 21"
      class="absolute bottom-[7.4rem] left-[1.7rem]"
    />
    <img
      src={~p"/images/vectors/vector22.svg"}
      alt="Vector 22"
      class="absolute bottom-[7.2rem] left-[1.4rem]"
    />
    <img
      src={~p"/images/vectors/vector23.svg"}
      alt="Vector 23"
      class="absolute top-[9rem] right-[1.7rem]"
    />
    """
  end

  defp get_episode_vector(random) do
    assigns = %{random: random}
    absolute_vectors(assigns)
  end

  defp episode_url(external_id, timestamp, podcast) when podcast in @samtripoliwebsite_podcasts do
    @episode_url_tinfoilhat <> external_id <> "?start=" <> timestamp
  end

  defp episode_url(external_id, timestamp, @podcast_lookintoit) do
    case Integer.parse(external_id) do
      {_integer, ""} ->
        @episode_url_rokfin <> external_id <> "?start=" <> timestamp

      _error ->
        @episode_url_rumble <> external_id <> "&start=" <> timestamp
    end
  end

  defp episode_url(external_id, timestamp, podcast) when podcast in @yt_podcasts do
    @episode_url_youtube <> external_id <> "?start=" <> timestamp
  end

  @spec trim_title(String.t()) :: String.t()
  def trim_title(<<title::binary-size(60), _rest::binary>>), do: title <> "..."
  def trim_title(title), do: title

  @spec trim_description(String.t()) :: String.t()
  def trim_description(<<description::binary-size(300), _rest::binary>>), do: description <> "..."
  def trim_description(description), do: description

  defp related_question_title_class(question_index) when Integer.is_odd(question_index),
    do: "text-base-content"

  defp related_question_title_class(_question_index), do: "text-primary"

  @spec get_time_from_seconds(integer()) :: String.t()
  def get_time_from_seconds(seconds) when is_integer(seconds) and seconds >= 0 do
    hours = div(seconds, 3600)
    minutes = div(rem(seconds, 3600), 60)
    secs = rem(seconds, 60)

    "#{pad(hours)}:#{pad(minutes)}:#{pad(secs)}"
  end

  defp pad(value) when value < 10, do: "0#{value}"
  defp pad(value), do: "#{value}"
end
