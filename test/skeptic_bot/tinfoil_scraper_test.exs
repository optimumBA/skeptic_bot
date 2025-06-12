defmodule SkepticBot.TinfoilScraperTest do
  use SkepticBot.DataCase, async: true

  import Mox
  import SkepticBot.PodcastsFixtures

  alias SkepticBot.DownloadingWorkerMock
  alias SkepticBot.EmbeddingMock
  alias SkepticBot.Podcasts.TinfoilScraper
  alias SkepticBot.ReqClientMock
  alias SkepticBot.TigrisMock
  alias SkepticBot.TranscriptionMock

  defp create_scraper_resources(_attrs) do
    body = body_fixture()
    embedding = embedding_fixture()
    chunks = chunks_fixture()

    %{body: body, embedding: embedding, chunks: chunks}
  end

  describe "scrape/1" do
    setup [:create_scraper_resources]

    test "add the episode to db", %{body: body, embedding: embedding, chunks: chunks} do
      expect(ReqClientMock, :make_request, 1, fn _url ->
        {:ok, %Req.Response{status: 200, body: body}}
      end)

      expect(DownloadingWorkerMock, :process_with_flame, 1, fn _url, _arg1, _arg2 ->
        {:ok, "random.mp3"}
      end)

      expect(TranscriptionMock, :transcribe, 1, fn _audio_url ->
        {:ok, chunks}
      end)

      expect(TigrisMock, :delete_file, fn _filename ->
        :ok
      end)

      expect(EmbeddingMock, :generate, 2, fn _text ->
        {:ok, [embedding]}
      end)

      TinfoilScraper.scrape()

      job =
        Oban.Job
        |> where([j], j.worker == "SkepticBot.Podcasts.DownloadingWorker")
        |> order_by([j], desc: j.inserted_at)
        |> limit(1)
        |> SkepticBot.Repo.one()

      assert_enqueued([worker: SkepticBot.Podcasts.DownloadingWorker], 500)

      assert :ok =
               perform_job(SkepticBot.Podcasts.DownloadingWorker, job.args)

      assert_enqueued([worker: SkepticBot.Podcasts.TranscribingWorker], 500)

      assert :ok =
               perform_job(SkepticBot.Podcasts.TranscribingWorker, %{
                 "id" => job.args["id"],
                 "audio_url" => "random.mp3"
               })

      assert_enqueued([worker: SkepticBot.Rag.EmbeddingsGeneratingWorker], 500)

      assert :ok =
               perform_job(SkepticBot.Rag.EmbeddingsGeneratingWorker, %{
                 "id" => job.args["id"]
               })
    end
  end
end
