defmodule SkepticBot.SitemapTest do
  use SkepticBot.DataCase, async: true
  use SkepticBotWeb, :verified_routes

  import SkepticBot.PromptsFixtures

  alias SkepticBot.Prompts
  alias SkepticBot.Sitemap

  setup do
    sitemap_dir = Path.join([:code.priv_dir(:skeptic_bot), "static"])
    File.mkdir_p!(sitemap_dir)
    File.chmod!(sitemap_dir, 0o755)
    :ok
  end

  describe "generate/0" do
    test "generates sitemap with homepage and questions" do
      question = question_fixture()

      assert {:ok, path} = Sitemap.generate(question)
      assert File.exists?(path)

      content = File.read!(path)

      assert content =~ ~s(<?xml version="1.0" encoding="UTF-8"?>)
      assert content =~ ~s(<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">)

      assert content =~ ~s(<url>)
      # Verify homepage URL exists (any valid URL format)
      assert content =~ ~r/<loc>[^<]*\/<\/loc>/
      assert content =~ ~s(<changefreq>daily</changefreq>)
      assert content =~ ~s(<priority>1.0</priority>)

      # Verify question URL exists with correct id
      assert content =~ ~r/<loc>[^<]*\/questions\/#{question.id}<\/loc>/
      assert content =~ ~s(<changefreq>monthly</changefreq>)
      assert content =~ ~s(<priority>0.8</priority>)

      assert content =~
               ~s(<lastmod>#{Date.to_iso8601(DateTime.to_date(question.updated_at))}</lastmod>)
    end

    test "handles special characters in URLs" do
      question = question_fixture(%{title: "Test & Special <Characters>"})

      assert {:ok, path} = Sitemap.generate(question)
      content = File.read!(path)

      # Verify question URL exists with correct id
      assert content =~ ~r/<loc>[^<]*\/questions\/#{question.id}<\/loc>/
    end

    test "generates valid XML" do
      question = question_fixture()

      assert {:ok, path} = Sitemap.generate(question)

      {element, []} =
        path
        |> File.read!()
        |> String.to_charlist()
        |> :xmerl_scan.string()

      assert element != nil
    end

    test "handles file system errors" do
      question = question_fixture()
      # Temporarily make the sitemap directory read-only
      sitemap_dir = Path.join([:code.priv_dir(:skeptic_bot), "static"])
      File.mkdir_p!(sitemap_dir)
      File.chmod!(sitemap_dir, 0o444)

      assert {:error, _err_message} = Sitemap.generate(question)

      # Restore permissions
      File.chmod!(sitemap_dir, 0o755)
    end
  end

  describe "error handling" do
    test "handles directory creation failure" do
      question = question_fixture()

      parent_dir = Path.join([:code.priv_dir(:skeptic_bot), "static"])
      File.mkdir_p!(parent_dir)
      File.chmod!(parent_dir, 0o444)

      assert {:error, "Failed to write sitemap file: :eacces"} = Sitemap.generate(question)

      File.chmod!(parent_dir, 0o755)
    end

    test "handles file update failure" do
      question = question_fixture()

      assert {:ok, path} = Sitemap.generate(question)

      File.chmod!(path, 0o444)

      assert {:error, "Failed to update sitemap file: " <> _error_msg} =
               Sitemap.generate(question)

      File.chmod!(path, 0o755)
    end
  end

  describe "XML pattern matching" do
    test "updates existing question entry correctly" do
      question = question_fixture()

      assert {:ok, _path} = Sitemap.generate(question)

      {:ok, updated_question} = Prompts.update_question(question, %{title: "Updated Title"})

      assert {:ok, path} = Sitemap.generate(updated_question)

      {:ok, content} = File.read(path)

      updated_date =
        updated_question.updated_at
        |> DateTime.to_date()
        |> Date.to_iso8601()

      assert content =~ ~r/<url>\s*<loc>.*\/questions\/#{question.id}<\/loc>/
      assert content =~ ~r/<lastmod>#{updated_date}<\/lastmod>/
    end

    test "handles special characters in URLs" do
      question = question_fixture(%{title: "Test & Special <Characters>"})

      assert {:ok, _path} = Sitemap.generate(question)

      {:ok, updated_question} =
        Prompts.update_question(question, %{title: "New & Special <Title>"})

      assert {:ok, path} = Sitemap.generate(updated_question)

      {:ok, content} = File.read(path)

      assert content =~ ~r/<url>\s*<loc>.*\/questions\/#{question.id}<\/loc>/
    end

    test "maintains XML structure when updating entries" do
      question = question_fixture()

      assert {:ok, _path} = Sitemap.generate(question)

      {:ok, updated_question} = Prompts.update_question(question, %{title: "First Update"})
      assert {:ok, _path} = Sitemap.generate(updated_question)

      {:ok, updated_question1} = Prompts.update_question(question, %{title: "Second Update"})
      assert {:ok, path} = Sitemap.generate(updated_question1)

      {:ok, content} = File.read(path)

      assert content =~ ~r/<\?xml version="1.0" encoding="UTF-8"\?>/
      assert content =~ ~r/<urlset xmlns="http:\/\/www\.sitemaps\.org\/schemas\/sitemap\/0\.9">/
      assert content =~ ~r/<\/urlset>/

      updated_date =
        updated_question1.updated_at
        |> DateTime.to_date()
        |> Date.to_iso8601()

      assert content =~ ~r/<url>\s*<loc>.*\/questions\/#{question.id}<\/loc>/
      assert content =~ ~r/<lastmod>#{updated_date}<\/lastmod>/
    end
  end
end
