defmodule SkepticBotWeb.PodcastComponents do
  @moduledoc """
  Dead components concerned with rendering podcast related content
  """

  use SkepticBotWeb, :html

  require Integer

  @type assigns :: map()
  @type rendered :: Phoenix.LiveView.Rendered.t()

  attr :external_id, :string, required: true
  attr :podcast_title, :string, required: true
  attr :random, :integer, required: true
  attr :thumbnail, :string, required: true
  attr :timestamp, :string, required: true
  attr :video_length, :string, required: true

  @spec episode_card(assigns()) :: rendered()
  def episode_card(assigns) do
    ~H"""
    <a href={"https://vid.samtripoli.com/w/" <> @external_id <> "?start=" <> @timestamp}>
      <section class="w-[19.6875rem] h-[19.6875rem] shrink-0 relative mobile-scroll-child">
        <div class="rounded-xl w-full h-full overflow-hidden">
          <img
            src={"https://vid.samtripoli.com/" <> @thumbnail}
            alt="Cover 2"
            class="w-full h-full object-cover"
          />
        </div>
        {get_episode_vector(@random)}
        <div class="absolute bottom-[3rem] left-[1rem] text-xl montserrat-alternates-bold text-[#FFFFFF]">
          {trim_title(@podcast_title)}
        </div>

        <div class="absolute bottom-[1rem] left-[1.2rem] flex gap-2 montserrat-alternates-semibold text-[#FFFFFF]">
          <div>
            <img src={~p"/images/podcasts/podcast_play.svg"} alt="Podcast Play Icon" />
          </div>
          <div class="text-sm">{get_time_from_seconds(@video_length)}</div>
        </div>
      </section>
    </a>
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
      class="border-2 border-[#000000] bg-[#FFFFFF] rounded-2xl cursor-pointer question-card-shadow"
      phx-click={JS.navigate(~p"/questions/#{@question_id}")}
    >
      <div class="flex flex-col px-3 pt-4 pb-2 text-[#4D4D4D]">
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
        <div class="text-sm w-[88%] montserrat-alternates-medium">
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

  @spec trim_title(String.t()) :: String.t()
  def trim_title(<<title::binary-size(60), _rest::binary>>), do: title <> "..."
  def trim_title(title), do: title

  @spec trim_description(String.t()) :: String.t()
  def trim_description(<<description::binary-size(300), _rest::binary>>), do: description <> "..."
  def trim_description(description), do: description

  defp related_question_title_class(question_index) when Integer.is_odd(question_index),
    do: "text-[#000000]"

  defp related_question_title_class(_question_index), do: "text-[#CD4631]"

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
