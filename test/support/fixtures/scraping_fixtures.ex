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
          "name" => "Tin Foil Hat",
          "thumbnailPath" => "/static/thumbnails/79e38851-0b10-46d5-80c5-cedc007cbf1e.jpg",
          "uuid" => "a909da70-43b7-5717-b1c0-c2d101521dc3"
        },
        %{
          "description" => "Is this a suitable description?",
          "duration" => 3000,
          "name" => "Cash Daddies 2",
          "thumbnailPath" => "/static/thumbnails/79e38851-0b10-46d5-80c5-cedc007cbf1e.jpg",
          "uuid" => "a909da70-13b7-4717-b1c0-c2d001521dc3"
        },
        %{
          "description" => "Is this a suitable description?",
          "duration" => 3000,
          "name" => "CashDaddies",
          "thumbnailPath" => "/static/thumbnails/79e38851-0b10-46d5-80c5-cedc007cbf1e.jpg",
          "uuid" => "a909da70-13b7-4717-b1c0-c2d001521dc3"
        },
        %{
          "description" => "Is this a suitable description?",
          "duration" => 3000,
          "name" => "Doom Scrollin",
          "thumbnailPath" => "/static/thumbnails/79e38851-0b10-46d5-80c5-cedc007cbf1e.jpg",
          "uuid" => "a909da80-14b7-4717-b1c0-c2d001521dc3"
        },
        %{
          "description" => "Is this a suitable description?",
          "duration" => 3000,
          "name" => "Doomscrollin",
          "thumbnailPath" => "/static/thumbnails/79e38851-0b10-46d5-80c5-cedc007cbf1e.jpg",
          "uuid" => "a909da80-14b7-4718-b1c0-c2s001521dc3"
        },
        %{
          "description" => "Is this a suitable description?",
          "duration" => 3000,
          "name" => "Opiate Of the Asses",
          "thumbnailPath" => "/static/thumbnails/79e38851-0b10-46d5-80c5-cedc007cbf1e.jpg",
          "uuid" => "a909da80-14b7-4717-b1h0-c2d011521dc4"
        },
        %{
          "description" => "Is this a suitable description?",
          "duration" => 3000,
          "name" => "OPIATE FOR",
          "thumbnailPath" => "/static/thumbnails/79e38851-0b10-46d5-80c5-cedc007cbf1e.jpg",
          "uuid" => "a909da80-14b7-4717-b1h0-c2d011521dc4"
        },
        %{
          "description" => "Is this a suitable description?",
          "duration" => 3000,
          "name" => "Union of the Unwanted",
          "thumbnailPath" => "/static/thumbnails/79e38851-0b10-46d5-80c5-cedc007cbf1e.jpg",
          "uuid" => "a908da81-12b7-4717-b1h0-c2d011521dc4"
        },
        %{
          "description" => "Is this a suitable description?",
          "duration" => 3000,
          "name" => "The Union of The Unwanted",
          "thumbnailPath" => "/static/thumbnails/79e38851-0b10-46d5-80c5-cedc007cbf1e.jpg",
          "uuid" => "a908da81-12b7-4717-b1h0-c2d011521dc4"
        },
        %{
          "description" => "Is this a suitable description?",
          "duration" => 3000,
          "name" => "Zero #178: Deadly",
          "thumbnailPath" => "/static/thumbnails/79e38851-0b10-46d5-80c5-cedc007cbf1e.jpg",
          "uuid" => "a908da82-12b7-4717-b1h0-c2d013581dc4"
        },
        %{
          "description" => "Is this a suitable description?",
          "duration" => 3000,
          "name" => "Broken Sim",
          "thumbnailPath" => "/static/thumbnails/79e38851-0b10-46d5-80c5-cedc007cbf1e.jpg",
          "uuid" => "a908da82-12c7-4717-b1h0-c2d063981dc4"
        },
        %{
          "description" => "Is this a suitable description?",
          "duration" => 3000,
          "name" => "BS Clips",
          "thumbnailPath" => "/static/thumbnails/79e38851-0b10-46d5-80c5-cedc007cbf1e.jpg",
          "uuid" => "a908da82-12c7-4717-b1h0-c2d063981dc4"
        },
        %{
          "description" => "Is this a suitable description?",
          "duration" => 3000,
          "name" => "Bad Advice",
          "thumbnailPath" => "/static/thumbnails/79e38851-0b10-46d5-80c5-cedc007cbf1e.jpg",
          "uuid" => "a908da82-12b7-4717-b1h0-c2d013581dc4"
        },
        %{
          "description" => "Is this a suitable description?",
          "duration" => 3000,
          "name" => "Black Crack Robots:  Sam Tripoli's First Crowd Work Special",
          "thumbnailPath" => "/static/thumbnails/79e38851-0b10-46d5-80c5-cedc007cbf1e.jpg",
          "uuid" => "a908da82-12b7-4717-b1h0-c2d013581dc4"
        },
        %{
          "description" => "Is this a suitable description?",
          "duration" => 3000,
          "name" => "OnlyConspiracies",
          "thumbnailPath" => "/static/thumbnails/79e38851-0b10-46d5-80c5-cedc007cbf1e.jpg",
          "uuid" => "a908da82-12b7-4717-b1h0-c2d013581dc4"
        },
        %{
          "description" => "Is this a suitable description?",
          "duration" => 3000,
          "name" => "Punch Drunk Sports",
          "thumbnailPath" => "/static/thumbnails/79e38851-0b10-46d5-80c5-cedc007cbf1e.jpg",
          "uuid" => "a908da82-12b7-4717-b1h0-c2d013581dc4"
        },
        %{
          "description" => "Is this a suitable description?",
          "duration" => 3000,
          "name" => "Saturday Night Deep Dives",
          "thumbnailPath" => "/static/thumbnails/79e38851-0b10-46d5-80c5-cedc007cbf1e.jpg",
          "uuid" => "a908da82-12b7-4717-b1h0-c2d013581dc4"
        },
        %{
          "description" => "Is this a suitable description?",
          "duration" => 3000,
          "name" => "Gay Heckler Gets Annihilated By Comic!",
          "thumbnailPath" => "/static/thumbnails/79e38851-0b10-46d5-80c5-cedc007cbf1e.jpg",
          "uuid" => "a908da82-12b7-4717-b1h0-c2d013581dc4"
        },
        %{
          "description" => "Is this a suitable description?",
          "duration" => 3000,
          "name" => "Deep Conspiracy Rewinds",
          "thumbnailPath" => "/static/thumbnails/79e38851-0b10-46d5-80c5-cedc007cbf1e.jpg",
          "uuid" => "a908da82-12b7-4717-b1h0-c2d013581dc4"
        },
        %{
          "description" => "Is this a suitable description?",
          "duration" => 3000,
          "name" => "Why is Everybody Gettin Quiet?",
          "thumbnailPath" => "/static/thumbnails/79e38851-0b10-46d5-80c5-cedc007cbf1e.jpg",
          "uuid" => "a908da82-12b7-4717-b1h0-c2d013581dc4"
        },
        %{
          "description" => "Is this a suitable description?",
          "duration" => 3000,
          "name" => "Comic Crushes Cougar Heckler!",
          "thumbnailPath" => "/static/thumbnails/79e38851-0b10-46d5-80c5-cedc007cbf1e.jpg",
          "uuid" => "a908da82-12b7-4717-b1h0-c2d013581dc4"
        }
      ]
    }
  end

  @spec rokfin_channel_fixture :: String.t()
  def rokfin_channel_fixture do
    "Episode #109$$6234.0$$https://rokfin.com/eyJidWNrZXQiOiJya2ZuLXBydsLzdmY$$https://rokfin.com/post/177589\n"
  end

  @spec rumble_channel_fixture :: String.t()
  def rumble_channel_fixture do
    "Episode #109$$6234$$https://rumble.com/eyJidWNrZXQiOiJya2ZuLXBydsLzdmY$$https://rumble.com/177589\n"
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
