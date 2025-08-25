defmodule SkepticBot.Prompts.QuestionsBroadcast do
  @moduledoc false

  alias SkepticBot.PubSub

  @type description :: String.t()
  @type message :: {message_type(), {title(), description()}}
  @type message_type :: atom()
  @type title :: String.t()
  @type topic :: String.t()

  @spec subscribe(topic()) :: :ok
  def subscribe(topic) do
    Phoenix.PubSub.subscribe(PubSub, topic)
  end

  @spec broadcast_title_and_description(topic(), message()) :: :ok
  def broadcast_title_and_description(topic, message) do
    Phoenix.PubSub.broadcast(
      PubSub,
      topic,
      message
    )
  end
end
