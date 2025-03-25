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
    <div class="grid grid-cols-5 gap-[0.8rem] picture-row pb-20 bg-[#FFF5F5]">
      <section class="relative rounded-r-xl overflow-hidden">
        <img src={~p"/images/cards/cover1.svg"} alt="Cover 1" class="w-full h-full object-cover" />

        <.socials />

        <img src={~p"/images/grid/vector1.svg"} alt="Vector 1" class="absolute bottom-[4rem] left-0" />

        <img
          src={~p"/images/grid/vector2.svg"}
          alt="Vector 2"
          class="absolute bottom-[4rem] right-[2.8rem]"
        />

        <img
          src={~p"/images/grid/vector3.svg"}
          alt="Vector 3"
          class="absolute top-[2.7rem] left-[2.4rem]"
        />

        <.podcast_title title="Tesla Autopilot" />
      </section>

      <section class="relative rounded-xl overflow-hidden">
        <img src={~p"/images/cards/cover2.svg"} alt="Cover 2" class="w-full h-full object-cover" />

        <.socials />

        <.absolute_vectors_2 />

        <.podcast_title title="Self-confidence" />
      </section>

      <section class="relative rounded-xl overflow-hidden">
        <img src={~p"/images/cards/cover3.svg"} alt="Cover 3" class="w-full h-full object-cover" />

        <.socials />

        <.absolute_vectors_3 />

        <.podcast_title title="Perplexed mind" />
      </section>

      <section class=" relative rounded-xl overflow-hidden">
        <img src={~p"/images/cards/cover4.svg"} alt="Cover 4" class="w-full h-full object-cover" />

        <.socials />
        <.absolute_vectors_4 />

        <.podcast_title title="Women's Rights" />
      </section>

      <section class="relative rounded-l-xl overflow-hidden">
        <img src={~p"/images/cards/cover5.svg"} alt="Cover 5" class="w-full h-full object-cover" />
        <.socials />

        <.absolute_vectors_5 />

        <.podcast_title title="Social Class" />
      </section>
    </div>
    """
  end

  def socials(assigns) do
    ~H"""
    <section class="absolute top-[0.8rem] right-[1.8rem] z-10 flex items-center gap-2">
      <.link
        href="https://vid.samtripoli.com/w/xoV9AbNuEQe9j9VAieVUxV"
        target="_blank"
        rel="noopener noreferrer"
      >
        <img src={~p"/images/media/spotify.svg"} alt="Spotify Logo" />
      </.link>

      <.link
        href="https://vid.samtripoli.com/w/xoV9AbNuEQe9j9VAieVUxV"
        target="_blank"
        rel="noopener noreferrer"
      >
        <img src={~p"/images/media/youtube.svg"} alt="YouTube Logo" />
      </.link>
    </section>
    """
  end

  def absolute_vectors_1(assigns) do
    ~H"""
    <img
      src={~p"/images/podcasts/podcast_vector1.svg"}
      alt="Podcast Vector 1"
      class="absolute bottom-[4rem] left-[3rem]"
    />

    <img
      src={~p"/images/podcasts/podcast_vector2.svg"}
      alt="Podcast Vector 2"
      class="absolute top-[-3rem] left-[-0.8rem]"
    />

    <img
      src={~p"/images/grid/vector3.svg"}
      alt="Vector 3"
      class="absolute top-[2.2rem] left-[9.7rem]"
    />
    <img
      src={~p"/images/grid/vector2.svg"}
      alt="Vector 2"
      class="absolute bottom-[4rem] right-[2.8rem]"
    />
    """
  end

  def absolute_grid_vectors_1(assigns) do
    ~H"""
    <img
      src={~p"/images/podcasts/podcast_vector1.svg"}
      alt="Podcast Vector 1"
      class="absolute bottom-[4rem] left-[3rem]"
    />

    <img
      src={~p"/images/grid/vector3.svg"}
      alt="Vector 3"
      class="absolute top-[2.2rem] left-[9.7rem]"
    />
    <img
      src={~p"/images/grid/vector2.svg"}
      alt="Vector 2"
      class="absolute bottom-[4rem] right-[2.8rem]"
    />
    """
  end

  def absolute_vectors_2(assigns) do
    ~H"""
    <img
      src={~p"/images/grid/star2.svg"}
      alt="Star 2"
      class="absolute bottom-[2.7rem] right-[6.7rem]"
    />
    <img src={~p"/images/grid/vector5.svg"} alt="Vector 5" class="absolute top-[3rem] right-[9rem]" />

    <img src={~p"/images/grid/vector4.svg"} alt="Vector 4" class="absolute top-[7.5rem] left-[7rem]" />
    """
  end

  def absolute_vectors_3(assigns) do
    ~H"""
    <img src={~p"/images/grid/vector7.svg"} alt="Vector 7" class="absolute top-[4.8rem] left-[6rem]" />
    """
  end

  def absolute_vectors_4(assigns) do
    ~H"""
    <img src={~p"/images/grid/vector8.svg"} alt="Vector 8" class="absolute top-0 left-0" />

    <img
      src={~p"/images/grid/vector9.svg"}
      alt="Vector 9"
      class="absolute bottom-[6.2rem] left-[7.8rem]"
    />

    <img
      src={~p"/images/grid/vector10.svg"}
      alt="Vector 10"
      class="absolute top-[7rem] left-[3.5rem]"
    />
    <img
      src={~p"/images/grid/vector11.svg"}
      alt="Vector 11"
      class="absolute top-[7.8rem] left-[2.9rem]"
    />
    <img
      src={~p"/images/grid/vector12.svg"}
      alt="Vector 12"
      class="absolute top-[4.9rem] right-[11.7rem]"
    />
    <img
      src={~p"/images/grid/vector13.svg"}
      alt="Vector 13"
      class="absolute top-[6.8rem] right-[5.2rem]"
    />
    <img
      src={~p"/images/grid/vector14.svg"}
      alt="Vector 14"
      class="absolute top-[9rem] right-[2.4rem]"
    />
    <img
      src={~p"/images/grid/vector15.svg"}
      alt="Vector 15"
      class="absolute top-[8.5rem] right-[1.8rem]"
    />
    <img
      src={~p"/images/grid/vector16.svg"}
      alt="Vector 16"
      class="absolute top-[8.75rem] right-[1.4rem]"
    />
    <img
      src={~p"/images/grid/vector17.svg"}
      alt="Vector 17"
      class="absolute top-[9.1rem] right-[1.7rem]"
    />
    """
  end

  def absolute_vectors_5(assigns) do
    ~H"""
    <img
      src={~p"/images/grid/vector18.svg"}
      alt="Vector 18"
      class="absolute top-[7rem] left-[1.7rem]"
    />
    <img
      src={~p"/images/grid/vector19.svg"}
      alt="Vector 19"
      class="absolute top-[7.8rem] left-[2.2rem]"
    />
    <img
      src={~p"/images/grid/vector20.svg"}
      alt="Vector 20"
      class="absolute top-[8rem] left-[1.8rem]"
    />
    <img
      src={~p"/images/grid/vector21.svg"}
      alt="Vector 21"
      class="absolute bottom-[7.4rem] left-[1.7rem]"
    />
    <img
      src={~p"/images/grid/vector22.svg"}
      alt="Vector 22"
      class="absolute bottom-[7.2rem] left-[1.4rem]"
    />
    <img
      src={~p"/images/grid/vector23.svg"}
      alt="Vector 23"
      class="absolute top-[9rem] right-[1.7rem]"
    />
    """
  end

  attr :title, :string, required: true

  def podcast_title(assigns) do
    ~H"""
    <div class="absolute bottom-[1rem] left-[0.8rem] text-3xl montserrat-alternates-bold text-[#FFFFFF]">
      <%= @title %>
    </div>
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
    <div class="border-2 border-[#000000] bg-[#FFFFFF] my-6 rounded-2xl card-shadow">
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

  attr :title, :string, required: true
  attr :title_color, :string, required: true
  attr :people_count, :string, required: true
  attr :body, :string, required: true

  def episode_card(assigns) do
    ~H"""
    <div class="border-2 border-[#000000] bg-[#FFFFFF] my-6 rounded-2xl card-shadow">
      <div class="flex flex-col px-3 pt-4 pb-2 text-[#4D4D4D]">
        <section class="flex justify-between items-center">
          <div class={["text-2xl montserrat-alternates-bold", @title_color]}><%= @title %></div>
          <div class="pr-4">
            <img src={~p"/images/cards/xmark.svg"} alt="X Mark" />
          </div>
        </section>
        <div class="divider">
          &zwj;
        </div>
        <section class="text-sm w-[88%] montserrat-alternates-medium">
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

  def twitter_component(assigns) do
    ~H"""
    <div class="pt-10 pb-4">
      <div class="divider bg-[#7F7F7F] w-[92%] mx-auto">
        &zwj;
      </div>

      <.link href="https://x.com/optimumBA">
        <div class="w-[10%] mx-auto border border-[#532822] rounded-custom my-12">
          <section class="py-3 w-[98%] mx-auto flex gap-2 justify-center items-center">
            <div>
              <img src={~p"/images/home/twitter.svg"} alt="Twitter Icon" />
            </div>
            <div class="text-[#532822] text-lg red-hat-display-bold">Twitter</div>
          </section>
        </div>
      </.link>
    </div>
    """
  end

  defp get_clip_image_src(filename) do
    ~p"/images/clips/#{filename}"
  end
end
