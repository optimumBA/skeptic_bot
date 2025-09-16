alias SkepticBot.Podcasts
alias SkepticBot.Podcasts.ReqDownloader
alias SkepticBot.YtDlp.EpisodeProcessor

format_channel_data = fn result ->
  result
  |> String.split("\n")
  |> Enum.map(fn x ->
    x
    |> String.split("~~")
    |> List.to_tuple()
  end)
  |> Enum.drop(-1)
end

get_episodes = fn path ->
  path
  |> File.read!()
  |> format_channel_data.()
end

file_url =
  System.get_env("NEPHILIM_TXT_FILE_URL") ||
    raise """
    environment variable NEPHILIM_TXT_FILE_URL is missing.
    """

path = Path.join([System.tmp_dir!(), "nephilim_death_squad.txt"])

{:ok, path} = ReqDownloader.download(file_url, path)

podcast = Podcasts.get_podcast_by_name("Nephilim Death Squad")

path
|> get_episodes.()
|> Enum.take(2)
|> Enum.each(
  &EpisodeProcessor.maybe_download_episode(
    &1,
    "https://www.youtube.com/@NephilimDeathSquad/streams",
    podcast
  )
)
