defmodule SkepticBot.Podcasts.ScrapingWorker do
  @moduledoc """
  Worker responsible for scheduled scraping of podcast episodes.
  Runs on an hourly basis to fetch new episodes.
  """

  use Oban.Worker,
    max_attempts: 1,
    queue: :scraping

  alias SkepticBot.Podcasts.TinfoilScraper

  require Logger

  @impl Oban.Worker
  def perform(_job) do
    Logger.info("Starting scheduled podcast scraping")
    TinfoilScraper.scrape()
    SkepticBot.Candace.Scraper.scrape()
    SkepticBot.DeepWaters.Scraper.scrape()
    SkepticBot.NephilimDeathSquad.Scraper.scrape()
  end
end
