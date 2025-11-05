import SkepticBot.YtDlp.Helpers

alias SkepticBot.Podcasts
alias SkepticBot.YtDlp.ChannelClient

channel = "https://www.youtube.com/@RealCandaceO/streams"
podcast = "Candace"

cookie_file = Application.get_env(:skeptic_bot, :youtube_cookie_file_path)

date = System.get_env("SCRAPE_DATEAFTER") || raise "SCRAPE_DATEAFTER is not set"

cmd =
  "yt-dlp --cache-dir #{System.tmp_dir!()} --dateafter #{date} --cookies #{cookie_file} --print \"%(title)s~~%(duration)s~~%(thumbnail)s~~%(webpage_url)s\" #{channel}"

port = Port.open({:spawn, cmd}, [:binary, :stderr_to_stdout, :exit_status])
Process.send_after(self(), {:close_port, port}, :timer.minutes(5))
podcast = Podcasts.get_podcast_by_name(podcast)
wait_for_episodes(channel, podcast)

# System.put_env("SCRAPE_DATEAFTER", "20250801")
# Code.eval_file(Path.join([:code.priv_dir(:skeptic_bot), "download_missing_episodes.exs"]))
