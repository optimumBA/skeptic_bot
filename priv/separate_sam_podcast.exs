defmodule SeparateSamPodcasts do
  import Ecto.Query, warn: false

  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.Episode
  alias SkepticBot.Repo

  require Logger

  def start do
    Logger.debug("Starting to separate Sam's podcasts", ansi_color: :green)

    podcast = Podcasts.get_podcast_by_name("Tin Foil Hat")
    podcast_2 = Podcasts.get_podcast_by_name("Doom Scrollin")
    podcast_3 = Podcasts.get_podcast_by_name("Cash Daddies")
    podcast_4 = Podcasts.get_podcast_by_name("Opiate of the Asses")
    podcast_5 = Podcasts.get_podcast_by_name("Zero with Sam Tripoli")
    podcast_6 = Podcasts.get_podcast_by_name("Union of the Unwanted")

    podcast_ids = [podcast_2.id, podcast_3.id, podcast_4.id, podcast_5.id, podcast_6.id]

    Episode
    |> where([e], e.podcast_id == ^podcast.id)
    |> Repo.all()
    |> Enum.each(&update_episode(&1.title, &1, podcast_ids))

    Logger.debug("Finished separating Sam's podcasts", ansi_color: :green)
  end

  defp update_episode(
         <<"Doom ", _remainder_title::binary>>,
         episode,
         [podcast_2_id, _podcast_3_id, _podcast_4_id, _podcast_5_id, _podcast_6_id]
       ) do
    Podcasts.update_episode(episode, %{podcast_id: podcast_2_id})
  end

  defp update_episode(
         <<"Doomscrollin", _remainder_title::binary>>,
         episode,
         [podcast_2_id, _podcast_3_id, _podcast_4_id, _podcast_5_id, _podcast_6_id]
       ) do
    Podcasts.update_episode(episode, %{podcast_id: podcast_2_id})
  end

  defp update_episode(
         <<"Cash Daddies", _remainder_title::binary>>,
         episode,
         [_podcast_2_id, podcast_3_id, _podcast_4_id, _podcast_5_id, _podcast_6_id]
       ) do
    Podcasts.update_episode(episode, %{podcast_id: podcast_3_id})
  end

  defp update_episode(
         <<"CashDaddies", _remainder_title::binary>>,
         episode,
         [_podcast_2_id, podcast_3_id, _podcast_4_id, _podcast_5_id, _podcast_6_id]
       ) do
    Podcasts.update_episode(episode, %{podcast_id: podcast_3_id})
  end

  defp update_episode(
         <<"Opiate ", _remainder_title::binary>>,
         episode,
         [_podcast_2_id, _podcast_3_id, podcast_4_id, _podcast_5_id, _podcast_6_id]
       ) do
    Podcasts.update_episode(episode, %{podcast_id: podcast_4_id})
  end

  defp update_episode(
         <<"OPIATE FOR", _remainder_title::binary>>,
         episode,
         [_podcast_2_id, _podcast_3_id, podcast_4_id, _podcast_5_id, _podcast_6_id]
       ) do
    Podcasts.update_episode(episode, %{podcast_id: podcast_4_id})
  end

  defp update_episode(
         <<"Opiates Of", _remainder_title::binary>>,
         episode,
         [_podcast_2_id, _podcast_3_id, podcast_4_id, _podcast_5_id, _podcast_6_id]
       ) do
    Podcasts.update_episode(episode, %{podcast_id: podcast_4_id})
  end

  defp update_episode(
         <<"Zero #", _remainder_title::binary>>,
         episode,
         [_podcast_2_id, _podcast_3_id, _podcast_4_id, podcast_5_id, _podcast_6_id]
       ) do
    Podcasts.update_episode(episode, %{podcast_id: podcast_5_id})
  end

  defp update_episode(
         <<"Union of the Unwanted", _remainder_title::binary>>,
         episode,
         [_podcast_2_id, _podcast_3_id, _podcast_4_id, _podcast_5_id, podcast_6_id]
       ) do
    Podcasts.update_episode(episode, %{podcast_id: podcast_6_id})
  end

  defp update_episode(
         <<"The Union of The Unwanted", _remainder_title::binary>>,
         episode,
         [_podcast_2_id, _podcast_3_id, _podcast_4_id, _podcast_5_id, podcast_6_id]
       ) do
    Podcasts.update_episode(episode, %{podcast_id: podcast_6_id})
  end

  defp update_episode(_episode_title, _episode, _podcast_ids), do: :ok
end

SeparateSamPodcasts.start()
