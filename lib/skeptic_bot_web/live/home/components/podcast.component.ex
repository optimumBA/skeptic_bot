defmodule SkepticBotWeb.PodcastComponent do
  @moduledoc """
  Dead components associated with rendering podcast related content
  """

  use SkepticBotWeb, :html
  use Phoenix.Component

  alias SkepticBotWeb.Home.Component

  attr :image_file, :string, required: true
  attr :podcast_title, :string, required: true
  attr :video_length, :string, required: true
  attr :random, :integer, required: true

  def podcast_video_card(assigns) do
    ~H"""
    <section class="w-[19.6875rem] h-[19.6875rem] shrink-0 relative">
      <div class="rounded-xl w-full h-full overflow-hidden">
        <img
          src={get_podcast_thumbnail(@image_file)}
          alt="Cover 2"
          class="w-full h-full object-cover"
        />
      </div>

      <Component.socials />

      <%= get_the_vector_randomly(@random) %>

      <div class="podcast-title text-3xl montserrat-alternates-bold text-[#FFFFFF]">
        <%= @podcast_title %>
      </div>

      <div class="podcast-length flex gap-2 montserrat-alternates-bold text-[#FFFFFF]">
        <div>
          <img src={~p"/images/podcasts/podcast_play.svg"} alt="Podcast Play Icon" />
        </div>
        <div class="text-sm"><%= @video_length %></div>
      </div>
    </section>
    """
  end

  defp get_podcast_thumbnail(filename) do
    ~p"/images/podcasts/#{filename}"
  end

  defp get_the_vector_randomly(random) do
    assigns = %{}

    cond do
      random == 1 -> Component.absolute_vectors_1(assigns)
      random == 2 -> Component.absolute_vectors_2(assigns)
      random == 3 -> Component.absolute_vectors_3(assigns)
      random == 4 -> Component.absolute_vectors_4(assigns)
      random == 5 -> Component.absolute_vectors_5(assigns)
    end
  end
end
