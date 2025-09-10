defmodule SkepticBotWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use SkepticBotWeb, :controller` and
  `use SkepticBotWeb, :live_view`.
  """
  use SkepticBotWeb, :html

  @type assigns :: map()
  @type rendered :: Phoenix.LiveView.Rendered.t()

  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  @spec app(assigns()) :: rendered()
  def app(assigns) do
    ~H"""
    <main>
      <div class="mx-auto">
        <.flash_group flash={@flash} />
        {@inner_content}
      </div>
    </main>
    """
  end
end
