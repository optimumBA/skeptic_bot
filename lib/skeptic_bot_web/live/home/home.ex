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
        <div class="image-title text-3xl">Social Class</div>
      </section>
    </div>
    """
  end
end
