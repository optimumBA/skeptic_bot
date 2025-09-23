defmodule SeparateSamPodcasts do
  import Ecto.Query, warn: false

  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.Episode
  alias SkepticBot.Podcasts.TinfoilScraper
  alias SkepticBot.Repo

  @podcast_brokensimulation "Broken Simulation"
  @podcast_cashdaddies "Cash Daddies"
  @podcast_doomscrollin "Doom Scrollin"
  @podcast_tinfoilhat "Tin Foil Hat"
  @podcast_unionoftheunwanted "Union of the Unwanted"
  @podcast_zerowithsamtripoli "Zero with Sam Tripoli"

  require Logger

  def start do
    Logger.info("Starting to separate Sam's podcasts", ansi_color: :green)

    podcasts = TinfoilScraper.get_podcasts()

    podcast = Podcasts.get_podcast_by_name(@podcast_tinfoilhat)

    transformation = fn ->
      Episode
      |> where([e], e.podcast_id == ^podcast.id)
      |> Repo.stream(max_rows: 100)
      |> Stream.each(&process_episode(&1.title, &1, podcasts))
      |> Stream.run()
    end

    Repo.transaction(transformation, timeout: :infinity)

    Logger.info("Finished separating Sam's podcasts", ansi_color: :green)
  end

  defp process_episode(
         "Comic Crushes Cougar Heckler!",
         episode,
         podcasts
       ),
       do: Repo.delete(episode)

  defp process_episode(
         "Why is Everybody Gettin Quiet?",
         episode,
         podcasts
       ),
       do: Repo.delete(episode)

  defp process_episode(
         "Gay Heckler Gets Annihilated By Comic!",
         episode,
         podcasts
       ),
       do: Repo.delete(episode)

  defp process_episode(
         "POTTY MOUTH (Crowd Work Special #2) From Sam Tripoli",
         episode,
         podcasts
       ),
       do: Repo.delete(episode)

  defp process_episode(
         "Black Crack Robots:  Sam Tripoli's First Crowd Work Special",
         episode,
         podcasts
       ),
       do: Repo.delete(episode)

  defp process_episode(
         <<"Deep Conspiracy Rewinds", _remainder_title::binary>>,
         episode,
         podcasts
       ),
       do: Repo.delete(episode)

  defp process_episode(
         <<"Punch Drunk Sports", _remainder_title::binary>>,
         episode,
         podcasts
       ),
       do: Repo.delete(episode)

  defp process_episode(
         <<"Bad Advice", _remainder_title::binary>>,
         episode,
         podcasts
       ),
       do: Repo.delete(episode)

  defp process_episode(
         <<"OnlyConspiracies", _remainder_title::binary>>,
         episode,
         podcasts
       ),
       do: Repo.delete(episode)

  defp process_episode(
         <<"Saturday Night Deep Dives", _remainder_title::binary>>,
         episode,
         podcasts
       ),
       do: Repo.delete(episode)

  defp process_episode(
         <<"OOTA", _remainder_title::binary>>,
         episode,
         podcasts
       ),
       do: Repo.delete(episode)

  defp process_episode(
         <<"Opiate ", _remainder_title::binary>>,
         episode,
         podcasts
       ),
       do: Repo.delete(episode)

  defp process_episode(
         <<"OPIATE FOR", _remainder_title::binary>>,
         episode,
         podcasts
       ),
       do: Repo.delete(episode)

  defp process_episode(
         <<"Opiates Of", _remainder_title::binary>>,
         episode,
         podcasts
       ),
       do: Repo.delete(episode)

  defp process_episode(
         <<"Broken Sim", _remainder_title::binary>>,
         episode,
         podcasts
       ) do
    podcast_id = podcasts[@podcast_brokensimulation]
    Podcasts.update_episode(episode, %{podcast_id: podcast_id})
  end

  defp process_episode(
         <<"BS Clips", _remainder_title::binary>>,
         episode,
         podcasts
       ) do
    podcast_id = podcasts[@podcast_brokensimulation]
    Podcasts.update_episode(episode, %{podcast_id: podcast_id})
  end

  defp process_episode(
         <<"Doom ", _remainder_title::binary>>,
         episode,
         podcasts
       ) do
    podcast_id = podcasts[@podcast_doomscrollin]
    Podcasts.update_episode(episode, %{podcast_id: podcast_id})
  end

  defp process_episode(
         <<"Doomscrollin", _remainder_title::binary>>,
         episode,
         podcasts
       ) do
    podcast_id = podcasts[@podcast_doomscrollin]
    Podcasts.update_episode(episode, %{podcast_id: podcast_id})
  end

  defp process_episode(
         <<"Cash Daddies", _remainder_title::binary>>,
         episode,
         podcasts
       ) do
    podcast_id = podcasts[@podcast_cashdaddies]
    Podcasts.update_episode(episode, %{podcast_id: podcast_id})
  end

  defp process_episode(
         <<"CashDaddies", _remainder_title::binary>>,
         episode,
         podcasts
       ) do
    podcast_id = podcasts[@podcast_cashdaddies]
    Podcasts.update_episode(episode, %{podcast_id: podcast_id})
  end

  defp process_episode(
         <<"Zero #", _remainder_title::binary>>,
         episode,
         podcasts
       ) do
    podcast_id = podcasts[@podcast_zerowithsamtripoli]
    Podcasts.update_episode(episode, %{podcast_id: podcast_id})
  end

  defp process_episode(
         <<"Union of the Unwanted", _remainder_title::binary>>,
         episode,
         podcasts
       ) do
    podcast_id = podcasts[@podcast_unionoftheunwanted]
    Podcasts.update_episode(episode, %{podcast_id: podcast_id})
  end

  defp process_episode(
         <<"The Union of The Unwanted", _remainder_title::binary>>,
         episode,
         podcasts
       ) do
    podcast_id = podcasts[@podcast_unionoftheunwanted]
    Podcasts.update_episode(episode, %{podcast_id: podcast_id})
  end

  defp process_episode(_episode_title, episode, podcasts), do: :ok
end

SeparateSamPodcasts.start()
