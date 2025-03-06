defmodule SkepticBotWeb.Header do
  @moduledoc """
  Renders the header as a child liveview inside
  every page
  """
  use SkepticBotWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket, layout: false}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex justify-between">
      <section class="ml-20">Logo</section>
      <section class="mr-20">RECENT EPISODES</section>
    </div>
    """
  end
end
