defmodule SkepticBot.Podcasts.ScrapingWorker do
  @moduledoc """
  Worker responsible for scheduled scraping of podcast episodes.
  Runs on an hourly basis to fetch new episodes.
  """

  use Oban.Worker,
    max_attempts: 3,
    queue: :scraping

  # alias SkepticBot.Podcasts.TinfoilScraper
  alias SkepticBot.YtDlp.Scraper

  require Logger

  @type job :: Oban.Job.t()

  @impl Oban.Worker
  @spec perform(job()) :: :ok | {:error, any()}
  def perform(_job) do
    Logger.info("Starting scheduled podcast scraping")
    # TinfoilScraper.scrape()
    Scraper.scrape("https://www.youtube.com/@RealCandaceO")
  end
end
