alias SkepticBot.Podcasts
alias SkepticBot.Podcasts.Episode
alias SkepticBot.Repo

require Logger

Logger.debug("Update is starting", ansi_color: :green)

{:ok, podcast} = Podcasts.create_podcast(%{name: "Tin Foil Hat"})
Podcasts.create_podcast(%{name: "Look Into It"})

Episode
|> Repo.all()
|> Enum.each(fn episode ->
  Podcasts.update_episode_podcast_id(episode, %{podcast_id: podcast.id})
end)

Logger.debug("Update is completed", ansi_color: :green)
