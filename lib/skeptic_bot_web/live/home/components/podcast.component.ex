defmodule SkepticBotWeb.PodcastComponent do
  @moduledoc """
  Dead components associated with rendering podcast related content
  """

  use SkepticBotWeb, :html
  use Phoenix.Component

  alias SkepticBotWeb.Home.Component

  attr :image_file, :string, required: true

  def podcast_video_card(assigns) do
    ~H"""
    <section class="w-[19.6875rem] h-[19.6875rem] shrink-0 relative rounded-xl overflow-hidden">
      <img src={get_podcast_thumbnail(@image_file)} alt="Cover 2" class="w-full h-full object-cover" />

      <Component.socials />

      <Component.absolute_vectors_2 />

      <.podcast_title title="Self-confidence" />
    </section>
    """
  end

  attr :title, :string, required: true

  def podcast_title(assigns) do
    ~H"""
    <div class="image-title text-3xl montserrat-alternates-bold text-[#FFFFFF]">
      <%= @title %>
    </div>
    """
  end

  defp get_podcast_thumbnail(filename) do
    ~p"/images/podcasts/#{filename}"
  end
end
