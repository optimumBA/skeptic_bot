defmodule SkepticBot.Workers.SitemapGeneratorWorker do
  @moduledoc false

  use Oban.Worker, queue: :seo_sitemap, max_attempts: 3

  alias SkepticBot.Prompts
  alias SkepticBot.Prompts.UserQuestion
  alias SkepticBot.Sitemap

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"question_id" => id}}) do
    case Prompts.get_question(id) do
      %UserQuestion{} = question ->
        Sitemap.generate(question)

      nil ->
        {:error, "Question not found"}
    end
  end

  def perform(%Oban.Job{args: %{}}) do
    Sitemap.generate_full()
  end
end
