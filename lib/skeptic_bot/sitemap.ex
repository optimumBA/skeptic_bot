defmodule SkepticBot.Sitemap do
  @moduledoc """
  Handles sitemap generation for SkepticBot.
  """

  use SkepticBotWeb, :verified_routes

  alias SkepticBot.Prompts
  alias SkepticBot.Prompts.UserQuestion

  @type path :: String.t()
  @type question :: UserQuestion.t()
  @type reason :: String.t()

  @doc """
  Generates or updates the sitemap.
  When called with a question, it updates the sitemap with that question.
  When called without arguments, it generates a new sitemap with all questions.
  Returns {:ok, path} on success or {:error, reason} on failure.
  """
  @spec generate(question()) :: {:ok, path()} | {:error, reason()}
  def generate(question) do
    with sitemap_dir <- Path.join([:code.priv_dir(:skeptic_bot), "static"]),
         :ok <- File.mkdir_p(sitemap_dir),
         sitemap_path <- Path.join([sitemap_dir, "sitemap.xml"]) do
      case {question, File.exists?(sitemap_path)} do
        {_question, false} ->
          generate_full_sitemap(sitemap_path)

        {question, true} ->
          update_sitemap_with_question(question, sitemap_path)
      end
    end
  end

  @doc """
  Generates a full sitemap with all questions.
  Returns {:ok, path} on success or {:error, reason} on failure.
  """
  @spec generate_full :: {:ok, path()} | {:error, reason()}
  def generate_full do
    with sitemap_dir <- Path.join([:code.priv_dir(:skeptic_bot), "static"]),
         :ok <- File.mkdir_p(sitemap_dir),
         sitemap_path <- Path.join([sitemap_dir, "sitemap.xml"]) do
      generate_full_sitemap(sitemap_path)
    end
  end

  defp generate_full_sitemap(sitemap_path) do
    questions = Prompts.list_questions()
    sitemap_content = generate_sitemap_content(questions)

    case File.write(sitemap_path, sitemap_content) do
      :ok ->
        {:ok, sitemap_path}

      {:error, reason} ->
        {:error, "Failed to write sitemap file: #{inspect(reason)}"}
    end
  end

  defp update_sitemap_with_question(question, sitemap_path) do
    with {:ok, content} <- File.read(sitemap_path),
         updated_content <- update_sitemap_content(content, question),
         :ok <- File.write(sitemap_path, updated_content) do
      {:ok, sitemap_path}
    else
      {:error, reason} ->
        {:error, "Failed to update sitemap file: #{inspect(reason)}"}
    end
  end

  defp generate_sitemap_content(questions) do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    <url>
      <loc>#{escape_xml(url(~p"/"))}</loc>
      <changefreq>daily</changefreq>
      <priority>1.0</priority>
    </url>
    #{questions_elements(questions)}
    </urlset>
    """
  end

  defp questions_elements(questions) do
    Enum.map_join(questions, "\n", &question_element/1)
  end

  defp question_element(%UserQuestion{id: id, updated_at: updated_at}) do
    last_modified =
      updated_at
      |> DateTime.to_date()
      |> Date.to_iso8601()

    """
    <url>
      <loc>#{escape_xml(url(~p"/questions/#{id}"))}</loc>
      <lastmod>#{last_modified}</lastmod>
      <changefreq>monthly</changefreq>
      <priority>0.8</priority>
    </url>
    """
  end

  defp escape_xml(string) do
    string
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&apos;")
  end

  defp update_sitemap_content(content, question) do
    question_element = question_element(question)
    question_url = url(~p"/questions/#{question.id}")

    if String.contains?(content, question_url) do
      pattern = ~r(<url>\s*<loc>#{Regex.escape(question_url)}</loc>.*?</url>)s
      String.replace(content, pattern, question_element)
    else
      String.replace(content, "</urlset>", "#{question_element}\n</urlset>")
    end
  end
end
