defmodule SkepticBotWeb.Home.Component do
  @moduledoc """
  Dead components associated with the home page
  """

  use SkepticBotWeb, :html
  use Phoenix.Component

  @doc """
  Renders the picture items with a Grid
  """

  def pictures(assigns) do
    ~H"""
    <div class="picture-grid pb-20 bg-[#FFF5F5]">
      <section class="relative rounded-r-xl overflow-hidden">
        <img src={~p"/images/cards/cover1.svg"} alt="Cover 1" class="w-full h-full object-cover" />

        <.socials />

        <img src={~p"/images/grid/vector1.svg"} alt="Vector 1" class="vector1" />

        <img src={~p"/images/grid/vector2.svg"} alt="Vector 2" class="vector2" />

        <img src={~p"/images/grid/vector3.svg"} alt="Vector 3" class="vector3" />
        <div class="image-title text-3xl montserrat-alternates-bold text-[#FFFFFF]">Autopilot</div>
      </section>

      <section class="relative rounded-xl overflow-hidden">
        <img src={~p"/images/cards/cover2.svg"} alt="Cover 2" class="w-full h-full object-cover" />

        <.socials />

        <.absolute_vectors_2 />

        <div class="image-title text-3xl montserrat-alternates-bold text-[#FFFFFF]">
          Self-confidence
        </div>
      </section>

      <section class="relative rounded-xl overflow-hidden">
        <img src={~p"/images/cards/cover3.svg"} alt="Cover 3" class="w-full h-full object-cover" />

        <.socials />

        <.absolute_vectors_3 />

        <div class="image-title text-3xl montserrat-alternates-bold text-[#FFFFFF]">
          Perplexed mind
        </div>
      </section>

      <section class="relative rounded-xl overflow-hidden">
        <img src={~p"/images/cards/cover4.svg"} alt="Cover 4" class="w-full h-full object-cover" />

        <.socials />
        <.absolute_vectors_4 />

        <div class="image-title text-3xl montserrat-alternates-bold text-[#FFFFFF]">
          Women's Rights
        </div>
      </section>

      <section class="relative rounded-l-xl overflow-hidden">
        <img src={~p"/images/cards/cover5.svg"} alt="Cover 5" class="w-full h-full object-cover" />
        <.socials />

        <.absolute_vectors_5 />

        <div class="image-title text-3xl montserrat-alternates-bold text-[#FFFFFF]">Social Class</div>
      </section>
    </div>
    """
  end

  def socials(assigns) do
    ~H"""
    <section class="social-media-card flex items-center gap-2">
      <div>
        <img src={~p"/images/media/spotify.svg"} alt="Spotify Logo" />
      </div>
      <div>
        <img src={~p"/images/media/youtube.svg"} alt="YouTube Logo" />
      </div>
    </section>
    """
  end

  def absolute_vectors_2(assigns) do
    ~H"""
    <img src={~p"/images/grid/star2.svg"} alt="Star 2" class="vector4" />
    <img src={~p"/images/grid/vector5.svg"} alt="Vector 5" class="vector5" />

    <img src={~p"/images/grid/vector4.svg"} alt="Vector 4" class="vector6" />
    """
  end

  def absolute_vectors_3(assigns) do
    ~H"""
    <img src={~p"/images/grid/vector7.svg"} alt="Vector 7" class="vector7" />
    """
  end

  def absolute_vectors_4(assigns) do
    ~H"""
    <img src={~p"/images/grid/vector8.svg"} alt="Vector 8" class="vector8" />

    <img src={~p"/images/grid/vector9.svg"} alt="Vector 9" class="vector9" />

    <img src={~p"/images/grid/vector10.svg"} alt="Vector 10" class="vector10" />
    <img src={~p"/images/grid/vector11.svg"} alt="Vector 11" class="vector11" />
    <img src={~p"/images/grid/vector12.svg"} alt="Vector 12" class="vector12" />
    <img src={~p"/images/grid/vector13.svg"} alt="Vector 13" class="vector13" />
    <img src={~p"/images/grid/vector14.svg"} alt="Vector 14" class="vector14" />
    <img src={~p"/images/grid/vector15.svg"} alt="Vector 15" class="vector15" />
    <img src={~p"/images/grid/vector16.svg"} alt="Vector 16" class="vector16" />
    <img src={~p"/images/grid/vector17.svg"} alt="Vector 17" class="vector17" />
    """
  end

  def absolute_vectors_5(assigns) do
    ~H"""
    <img src={~p"/images/grid/vector18.svg"} alt="Vector 18" class="vector18" />
    <img src={~p"/images/grid/vector19.svg"} alt="Vector 19" class="vector19" />
    <img src={~p"/images/grid/vector20.svg"} alt="Vector 20" class="vector20" />
    <img src={~p"/images/grid/vector21.svg"} alt="Vector 21" class="vector21" />
    <img src={~p"/images/grid/vector22.svg"} alt="Vector 22" class="vector22" />
    <img src={~p"/images/grid/vector23.svg"} alt="Vector 23" class="vector23" />
    """
  end

  @doc """
  Renders a card item
  """

  attr :title, :string, required: true
  attr :title_color, :string, required: true
  attr :people_count, :string, required: true
  attr :body, :string, required: true

  def card(assigns) do
    ~H"""
    <div class="border-2 border-[#000000] my-6 rounded-2xl card-shadow">
      <div class="px-3 py-8 text-[#4D4D4D]">
        <section class="flex justify-between items-center">
          <div class={["text-2xl montserrat-alternates-bold", @title_color]}><%= @title %></div>
          <div class="pr-4">
            <img src={~p"/images/cards/xmark.svg"} alt="X Mark" />
          </div>
        </section>
        <div class="divider">
          &zwj;
        </div>
        <section class="text-sm w-[78%] montserrat-alternates-medium">
          <%= @body %>...
        </section>
        <section class="flex justify-start items-center gap-2 py-4">
          <div>
            <img src={~p"/images/cards/ask.svg"} alt="Ask me" class="" />
          </div>
          <div class="text-xs montserrat-alternates-medium">
            Asked by <%= @people_count %> people
          </div>
        </section>
      </div>
    </div>
    """
  end

  @doc """
  Renders a clip card item
  """

  attr :image_file, :string, required: true
  attr :title, :any, required: true
  attr :author, :string, required: true
  attr :video_length, :string, required: true

  def clip(assigns) do
    ~H"""
    <div class="px-3 flex justify-start items-stretch gap-6 border border-[#CD4631] py-6 rounded-lg bg-[#F8F8F8] card-shadow z-50">
      <div class="shrink-0">
        <img src={get_clip_image_src(@image_file)} alt="Clip Item" />
      </div>
      <div class="flex flex-col items-start justify-between">
        <div class="montserrat-alternates-medium text-2xl text-[#532822] pr-2">
          <%= @title %>
        </div>
        <div class="text-[#383838] text-lg montserrat-alternates-regular"><%= @author %></div>

        <section class="flex justify-between gap-16 items-center">
          <div class="text-2xl text-[#383838] montserrat-alternates-semibold">
            <%= @video_length %>
          </div>
          <div>
            <img src={~p"/images/clips/playicon.svg"} width="55" alt="Play Icon" />
          </div>
        </section>
      </div>
    </div>
    """
  end

  defp get_clip_image_src(filename) do
    ~p"/images/clips/#{filename}"
  end
end
