defmodule SkepticBot.CheckPodcastEpisodes do
  import Ecto.Query

  require Logger

  alias SkepticBot.Repo
  alias SkepticBot.Podcasts.Episode
  alias SkepticBot.Storage.Tigris

  def run do
    episodes = get_all_episodes()

    timestamp = DateTime.utc_now() |> Calendar.strftime("%Y%m%d%H%M%S")
    output_file = "podcast_episodes_check_#{timestamp}.txt"

    file = File.open!(output_file, [:write, :utf8])

    Logger.info("Starting checks for #{length(episodes)} episodes...")
    Logger.info("Results will be written to #{output_file}")

    results =
      Task.async_stream(
        episodes,
        &check_episode/1,
        max_concurrency: 20,
        timeout: 30_000,
        ordered: true
      )
      |> Enum.map(fn {:ok, result} -> result end)

    display_results(results, file)

    File.close(file)

    Logger.info("Check completed. Results written to #{output_file}")
  end

  defp get_all_episodes do
    Repo.all(from e in Episode, select: %{id: e.id, external_id: e.external_id})
  end

  defp check_episode(episode) do
    downloading = check_job_status(episode.id, "downloading")
    transcribing = check_job_status(episode.id, "transcribing")
    embeddings = check_job_status(episode.id, "generating_embeddings")

    # Only check audio file if transcribing is in progress
    audio_file_exists =
      if transcribing[:exists] && transcribing[:state] != "completed" do
        check_audio_file_exists(transcribing)
      else
        false
      end

    %{
      id: episode.id,
      external_id: episode.external_id,
      downloading: downloading,
      transcribing: transcribing,
      embeddings: embeddings,
      audio_file_exists: audio_file_exists
    }
  end

  defp check_job_status(episode_id, queue) do
    query =
      from j in "oban_jobs",
        where: fragment("args->>'id' = ?", ^episode_id),
        where: j.queue == ^queue,
        select: %{
          state: j.state,
          inserted_at: j.inserted_at,
          completed_at: j.completed_at,
          audio_url: fragment("args->>'audio_url'")
        },
        order_by: [desc: j.inserted_at],
        limit: 1

    case Repo.one(query) do
      nil -> %{exists: false}
      job -> Map.put(job, :exists, true)
    end
  end

  defp check_audio_file_exists(%{exists: true, audio_url: audio_url}) when not is_nil(audio_url) do
    file_name = Path.basename(audio_url)

    # We need to check if the file exists in Tigris
    # This is a simplified approach since Tigris doesn't provide a direct way to check
    # if a file exists. We attempt to make a HEAD request to the file.
    req = Tigris.new()

    case Req.head(req, url: file_name) do
      {:ok, %{status: status}} when status in 200..299 -> true
      _ -> false
    end
  rescue
    _ -> false
  end

  defp check_audio_file_exists(_), do: false

  defp display_results(results, file) do
    IO.puts(file, "\n==== Podcast Episodes Processing Status ====\n")

    Enum.each(results, fn result ->
      IO.puts(file, "Episode ID: #{result.id}")
      IO.puts(file, "  External ID: #{result.external_id}")

      # Check downloading job
      case result.downloading do
        %{exists: false} ->
          IO.puts(file, "  ❌ No downloading job found")
        %{exists: true, state: "completed"} ->
          IO.puts(file, "  ✅ Downloading completed")
        %{exists: true, state: state} ->
          IO.puts(file, "  ⚠️  Downloading job state: #{state}")
      end

      # Check transcribing job and audio file
      case result.transcribing do
        %{exists: false} ->
          IO.puts(file, "  ❌ No transcribing job found")
        %{exists: true, state: "completed"} ->
          IO.puts(file, "  ✅ Transcribing completed (Audio: ✅ assumed deleted)")
        %{exists: true, state: state, audio_url: audio_url} ->
          audio_status = if result.audio_file_exists, do: "✅ exists", else: "❌ missing"
          IO.puts(file, "  ⚠️  Transcribing #{state} (Audio: #{audio_status}, URL: #{audio_url})")
      end

      # Check embedding generation job
      case {result.transcribing, result.embeddings} do
        {%{exists: true, state: "completed"}, %{exists: false}} ->
          IO.puts(file, "  ❌ Transcribing completed but no embeddings job found")
        {_, %{exists: false}} ->
          IO.puts(file, "  ⚠️  No embeddings job found (expected if transcribing not completed)")
        {_, %{exists: true, state: "completed"}} ->
          IO.puts(file, "  ✅ Embeddings generation completed")
        {_, %{exists: true, state: state}} ->
          IO.puts(file, "  ⚠️  Embeddings generation job state: #{state}")
      end

      IO.puts(file, "")
    end)

    # Print summary
    completed_count = Enum.count(results, fn r ->
      is_completed = fn job -> job[:exists] == true && job[:state] == "completed" end

      is_completed.(r.downloading) &&
      is_completed.(r.transcribing) &&
      is_completed.(r.embeddings)
    end)

    IO.puts(file, "Summary: #{completed_count}/#{length(results)} episodes fully processed")

    # List issues that need attention
    issues = Enum.filter(results, fn r ->
      downloading_issue = r.downloading[:exists] != true || r.downloading[:state] != "completed"
      transcribing_issue = r.transcribing[:exists] != true || r.transcribing[:state] != "completed"
      embeddings_issue = r.transcribing[:exists] == true &&
                         r.transcribing[:state] == "completed" &&
                         (r.embeddings[:exists] != true || r.embeddings[:state] != "completed")
      audio_missing_issue = r.transcribing[:exists] == true &&
                            r.transcribing[:state] != "completed" &&
                            !r.audio_file_exists

      downloading_issue || transcribing_issue || embeddings_issue || audio_missing_issue
    end)

    if length(issues) > 0 do
      IO.puts(file, "\n⚠️  Issues requiring attention (#{length(issues)} episodes):")
      Enum.each(issues, fn issue ->
        IO.puts(file, "  - Episode #{issue.id} (#{issue.external_id}): #{get_issue_description(issue)}")
      end)
    else
      IO.puts(file, "\n✅ No issues found requiring attention")
    end
  end

  defp get_issue_description(episode) do
    cond do
      episode.downloading[:exists] != true ->
        "Missing downloading job"
      episode.downloading[:exists] == true && episode.downloading[:state] != "completed" ->
        "Downloading job in state: #{episode.downloading[:state]}"
      episode.transcribing[:exists] != true ->
        "Missing transcribing job"
      episode.transcribing[:exists] == true && episode.transcribing[:state] != "completed" ->
        "Transcribing job in state: #{episode.transcribing[:state]}"
      episode.transcribing[:exists] == true && episode.transcribing[:state] == "completed" && episode.embeddings[:exists] != true ->
        "Transcribing completed but missing embeddings job"
      episode.transcribing[:exists] == true && episode.transcribing[:state] == "completed" &&
        episode.embeddings[:exists] == true && episode.embeddings[:state] != "completed" ->
        "Embeddings job in state: #{episode.embeddings[:state]}"
      episode.transcribing[:exists] == true && episode.transcribing[:state] != "completed" && !episode.audio_file_exists ->
        "Transcribing in progress but audio file is missing"
      true ->
        "Other issue"
    end
  end
end

SkepticBot.CheckPodcastEpisodes.run()
