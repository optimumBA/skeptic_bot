defmodule SkepticBot.TinfoilScraperTest do
  use SkepticBot.DataCase, async: true

  import Mox
  import SkepticBot.TinfoilScraperFixtures

  alias SkepticBot.DownloadingWorkerMock
  alias SkepticBot.EmbeddingMock
  alias SkepticBot.Podcasts
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

  defp get_job do
    Oban.Job
    |> where([j], j.worker == "SkepticBot.Podcasts.DownloadingWorker")
    |> order_by([j], desc: j.inserted_at)
    |> limit(1)
    |> SkepticBot.Repo.one()
  end

  describe "scrape/1" do
    setup [:create_scraper_resources]

    test "makes request to get episodes, downloads, trancribes, generates embeddings, and stores the episodes in the DB",
         %{body: body, embedding: embedding, chunks: chunks} do
      expect(ReqClientMock, :make_request, 1, fn _url ->
        {:ok, %Req.Response{status: 200, body: body}}
      end)

      expect(DownloadingWorkerMock, :process_with_flame, fn _url, _arg1, _arg2 ->
        {:ok, "random.mp3"}
      end)

      expect(TranscriptionMock, :transcribe, fn _audio_url ->
        {:ok, chunks}
      end)

      expect(TigrisMock, :delete_file, fn _filename ->
        :ok
      end)

      expect(EmbeddingMock, :generate, 2, fn _text ->
        {:ok, [embedding]}
      end)

      TinfoilScraper.scrape()

      job = get_job()

      id = job.args["id"]

      assert Podcasts.episode_exists?(job.args["external_id"]) == true

      assert_enqueued(worker: SkepticBot.Podcasts.DownloadingWorker, args: job.args)

      assert :ok =
               perform_job(SkepticBot.Podcasts.DownloadingWorker, job.args)

      assert_enqueued(
        worker: SkepticBot.Podcasts.TranscribingWorker,
        args: %{
          "id" => id,
          "audio_url" => "random.mp3"
        }
      )

      assert :ok =
               perform_job(SkepticBot.Podcasts.TranscribingWorker, %{
                 "id" => id,
                 "audio_url" => "random.mp3"
               })

      assert_enqueued(
        worker: SkepticBot.Rag.EmbeddingsGeneratingWorker,
        args: %{
          "id" => id
        }
      )

      assert :ok =
               perform_job(SkepticBot.Rag.EmbeddingsGeneratingWorker, %{
                 "id" => id
               })
    end

    test "with invalid data does not insert a job to be processed" do
      expect(ReqClientMock, :make_request, 1, fn _url ->
        {:error, "Could not make request"}
      end)

      TinfoilScraper.scrape()

      job = get_job()

      assert job == nil
    end
  end
end
