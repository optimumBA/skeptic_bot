defmodule SkepticBotWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use SkepticBotWeb, :html

  @type assigns :: map()
  @type rendered :: Phoenix.LiveView.Rendered.t()

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
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

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

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
