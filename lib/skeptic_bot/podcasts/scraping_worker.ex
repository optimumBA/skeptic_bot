defmodule SkepticBot.Podcasts.ScrapingWorker do
  @moduledoc """
  Worker responsible for scheduled scraping of podcast episodes.
  Runs on an hourly basis to fetch new episodes.
  """

  use Oban.Worker,
    max_attempts: 3,
    queue: :scraping

  alias SkepticBot.LookIntoIt.Scraper
  alias SkepticBot.Podcasts.TinfoilScraper

  require Logger

  @type job :: Oban.Job.t()

  @rumble_channel "https://rumble.com/c/eddiebravo/videos?e9s=src_v1_sa%2Csrc_v1_sa_o"

  @impl Oban.Worker
  @spec perform(job()) :: :ok | {:error, any()}
  def perform(_job) do
    Logger.info("Starting scheduled podcast scraping")
    TinfoilScraper.scrape()
    Scraper.scrape(@rumble_channel)
  end
end
