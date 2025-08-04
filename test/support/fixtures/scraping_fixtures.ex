defmodule SkepticBot.ScrapingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities used in the scraping process.
  """

  @spec body_fixture :: map()
  def body_fixture do
    %{
      "data" => [
        %{
          "description" => "Is this a suitable description?",
          "duration" => 3000,
          "name" => "Cash Daddies 2",
          "thumbnailPath" => "/static/thumbnails/79e38851-0b10-46d5-80c5-cedc007cbf1e.jpg",
          "uuid" => "a909da70-13b7-4717-b1c0-c2d001521dc3"
        }
      ]
    }
  end

  @spec channel_fixture :: String.t()
  def channel_fixture do
    "Episode #109$$6234.0$$https://rokfin.com/eyJidWNrZXQiOiJya2ZuLXBydsLzdmY$$https://rokfin.com/post/177589$$https://rkfn-media.global.ssl.fastly.net/jGrM0w/v.mp4\n"
  end

  @spec chunks_fixture :: list()
  def chunks_fixture do
    [
      %{
        "text" => "Welcome to the episode!",
        "timestamp" => [0.0, 5.5]
      },
      %{
        "text" => "  We talk about functional programming.",
        "timestamp" => [5.5, 15.2]
      },
      %{
        "text" => "Thanks for listening!   ",
        "timestamp" => [nil, 20.0]
      }
    ]
  end
end
