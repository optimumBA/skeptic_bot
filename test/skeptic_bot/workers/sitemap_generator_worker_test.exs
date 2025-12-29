defmodule SkepticBot.Workers.SitemapGeneratorWorkerTest do
  use SkepticBot.DataCase, async: false

  import SkepticBot.PromptsFixtures

  alias SkepticBot.Workers.SitemapGeneratorWorker

  setup do
    on_exit(fn ->
      [:code.priv_dir(:skeptic_bot), "static", "sitemap.xml"]
      |> Path.join()
      |> File.rm()
    end)
  end

  describe "perform/1" do
    test "generates sitemap file successfully" do
      question = question_fixture()

      assert {:ok, path} = perform_job(SitemapGeneratorWorker, %{question_id: question.id})
      assert File.exists?(path)
      assert String.ends_with?(path, "sitemap.xml")
    end

    test "handles non-existent question_id" do
      assert {:error, "Question not found"} =
               perform_job(SitemapGeneratorWorker, %{"question_id" => Ecto.UUID.generate()})
    end

    test "handles file system errors" do
      question = question_fixture()
      # Temporarily make the sitemap directory read-only
      sitemap_dir = Path.join([:code.priv_dir(:skeptic_bot), "static"])
      File.mkdir_p!(sitemap_dir)
      File.chmod!(sitemap_dir, 0o444)

      assert {:error, _error_msg} =
               perform_job(SitemapGeneratorWorker, %{question_id: question.id})

      # Restore permissions
      File.chmod!(sitemap_dir, 0o755)
    end

    test "generates full sitemap when no question_id is provided" do
      _question = question_fixture()

      assert {:ok, path} = perform_job(SitemapGeneratorWorker, %{})
      assert File.exists?(path)
      assert String.ends_with?(path, "sitemap.xml")
    end

    test "generates empty sitemap when no questions exist and no question_id provided" do
      assert {:ok, path} = perform_job(SitemapGeneratorWorker, %{})
      assert File.exists?(path)
      assert String.ends_with?(path, "sitemap.xml")
    end
  end
end
