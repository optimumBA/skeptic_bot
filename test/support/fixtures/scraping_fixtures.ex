defmodule SkepticBot.ScrapingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities used in the scraping process.
  """

  @type embedding :: [float()]

  @doc """
  create an embedding.
  """
  @spec embedding_fixture :: embedding()
  def embedding_fixture do
    Enum.map(1..1024, fn _some_random_float -> :rand.uniform() end)
  end

  @spec body_fixture :: map()
  def body_fixture do
    %{
      "data" => [
        %{
          "description" => "Is this a suitable description?",
          "name" => "Cash Daddies 2",
          "uuid" => "a909da70-13b7-4717-b1c0-c2d001521dc3"
        }
      ]
    }
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
