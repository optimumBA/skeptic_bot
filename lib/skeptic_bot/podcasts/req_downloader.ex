defmodule SkepticBot.Podcasts.ReqDownloader do
  @moduledoc false

  alias SkepticBot.Podcasts.Downloader

  @behaviour Downloader

  @impl Downloader
  def download(url, path) do
    case Req.get(
           url,
           raw: true,
           receive_timeout: 600_000,
           connect_options: [timeout: 60_000],
           retry: :transient,
           max_retries: 3,
           into: File.stream!(path, [:write, :binary, :delayed_write])
         ) do
      {:ok, %{status: status}} when status in 200..299 ->
        {:ok, path}

      {:ok, %{status: status}} ->
        {:error, "HTTP error: status #{status}"}

      error ->
        {:error, "Request error: #{inspect(error)}"}
    end
  rescue
    e -> {:error, "Download error: #{Exception.message(e)}"}
  end
end
