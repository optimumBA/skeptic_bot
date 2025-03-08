defmodule SkepticBotWeb.HomeLive.Index do
  @moduledoc """
  The home page containing the chat input.
  """

  use SkepticBotWeb, :live_view
  use Phoenix.Component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="bg-[#FFF5F5]">
        <%= live_render(@socket, SkepticBotWeb.Header,
          id: "live_header",
          sticky: true
        ) %>
      </div>

      <div class="flex justify-start items-start gap-20 h-screen bg-[#FFF5F5]">
        <section>
          <div class="top-swirl"><img src={~p"/images/home/top_swirl.svg"} alt="Swirl" /></div>
          <div class="illustration w-[20%]">
            <img src={~p"/images/home/illustration_1.svg"} alt="Illustration 1" />
          </div>

          <div class="stars w-[11%]">
            <img src={~p"/images/home/stars.png"} alt="Stars Group" />
          </div>
        </section>
        <section class="flex flex-col justify-start items-start pl-72 gap-8 w-full">
          <section class="text-8xl pt-40">
            Your Daily <span class="text-[#CD4631]">Podcast</span>
          </section>

          <section class="w-[70%] flex flex-col items-start gap-8">
            <section class="w-[35%] ml-52 text-center">
              Ask anything and get answers directly from trusted experts
            </section>
            <section class="ml-28 w-[68%]">
              <.live_component module={SkepticBotWeb.HomeLive.FormComponent} id="prompt form" />
            </section>
            <section class="ml-44 mt-48 relative w-[68%]">
              <section class="text-6xl">
                Popular Podcast
              </section>

              <div class="superscript-image w-[11%]">
                <img src={~p"/images/home/top_letter.svg"} alt="Superscript Image" />
              </div>
            </section>
          </section>
        </section>
      </div>

      <.pictures />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @doc """
  Renders the picture items
  """

  def pictures(assigns) do
    ~H"""
    <div class="picture-grid">
      <section class="relative rounded-r-xl overflow-hidden">
        <img src={~p"/images/cards/cover1.svg"} alt="Cover 1" class="w-full h-full object-cover" />

        <section class="social-media-card flex items-center gap-2">
          <div>
            <img src={~p"/images/media/spotify.svg"} alt="Spotify Logo" />
          </div>
          <div>
            <img src={~p"/images/media/youtube.svg"} alt="YouTube Logo" />
          </div>
        </section>

        <img src={~p"/images/grid/vector1.svg"} alt="Vector 1" class="vector1" />

        <img src={~p"/images/grid/vector2.svg"} alt="Vector 2" class="vector2" />

        <img src={~p"/images/grid/vector3.svg"} alt="Vector 3" class="vector3" />
        <div class="image-title text-3xl">Autopilot</div>
      </section>

      <section class="relative rounded-xl overflow-hidden">
        <img src={~p"/images/cards/cover2.svg"} alt="Cover 2" class="w-full h-full object-cover" />

        <section class="social-media-card flex items-center gap-2">
          <div>
            <img src={~p"/images/media/spotify.svg"} alt="Spotify Logo" />
          </div>
          <div>
            <img src={~p"/images/media/youtube.svg"} alt="YouTube Logo" />
          </div>
        </section>

        <img src={~p"/images/grid/star2.svg"} alt="Star 2" class="vector4" />
        <img src={~p"/images/grid/vector5.svg"} alt="Vector 5" class="vector5" />

        <img src={~p"/images/grid/vector4.svg"} alt="Vector 4" class="vector6" />

        <div class="image-title text-3xl">Self-confidence</div>
      </section>

      <section class="relative rounded-xl overflow-hidden">
        <img src={~p"/images/cards/cover3.svg"} alt="Cover 3" class="w-full h-full object-cover" />

        <section class="social-media-card flex items-center gap-2">
          <div>
            <img src={~p"/images/media/spotify.svg"} alt="Spotify Logo" />
          </div>
          <div>
            <img src={~p"/images/media/youtube.svg"} alt="YouTube Logo" />
          </div>
        </section>

        <img src={~p"/images/grid/vector7.svg"} alt="Vector 7" class="vector7" />
        <div class="image-title text-3xl">Perplexed mind</div>
      </section>

      <section class="relative rounded-xl overflow-hidden">
        <img src={~p"/images/cards/cover4.svg"} alt="Cover 4" class="w-full h-full object-cover" />

        <section class="social-media-card flex items-center gap-2">
          <div>
            <img src={~p"/images/media/spotify.svg"} alt="Spotify Logo" />
          </div>
          <div>
            <img src={~p"/images/media/youtube.svg"} alt="YouTube Logo" />
          </div>
        </section>

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

        <div class="image-title text-3xl">Women's Rights</div>
      </section>

      <section class="relative rounded-l-xl overflow-hidden">
        <img src={~p"/images/cards/cover5.svg"} alt="Cover 5" class="w-full h-full object-cover" />

        <section class="social-media-card flex items-center gap-2">
          <div>
            <img src={~p"/images/media/spotify.svg"} alt="Spotify Logo" />
          </div>
          <div>
            <img src={~p"/images/media/youtube.svg"} alt="YouTube Logo" />
          </div>
        </section>

        <img src={~p"/images/grid/vector18.svg"} alt="Vector 18" class="vector18" />
        <img src={~p"/images/grid/vector19.svg"} alt="Vector 19" class="vector19" />
        <img src={~p"/images/grid/vector20.svg"} alt="Vector 20" class="vector20" />
        <img src={~p"/images/grid/vector21.svg"} alt="Vector 21" class="vector21" />
        <img src={~p"/images/grid/vector22.svg"} alt="Vector 22" class="vector22" />
        <img src={~p"/images/grid/vector23.svg"} alt="Vector 23" class="vector23" />

        <div class="image-title text-3xl">Social Class</div>
      </section>
    </div>
    """
  end
end
