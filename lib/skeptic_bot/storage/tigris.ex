defmodule SkepticBot.Storage.Tigris do
  @moduledoc """
  Module for handling file uploads to Tigris Storage using S3-compatible API.
  """
  require Logger

  @timeout :timer.minutes(5)

  def new do
    config = Application.fetch_env!(:skeptic_bot, :tigris_storage)
    bucket = Keyword.fetch!(config, :bucket)

    Req.new(
      aws_sigv4: [
        service: :s3,
        access_key_id: Keyword.fetch!(config, :access_key_id),
        secret_access_key: Keyword.fetch!(config, :secret_access_key),
        region: "auto"
      ],
      base_url: "https://#{bucket}.fly.storage.tigris.dev",
      retry: :transient,
      receive_timeout: @timeout
    )
  end

  @doc """
  Uploads a file to Tigris Storage and returns the public URL.
  """
  def upload_file(file_path, content_type \\ "audio/mpeg") do
    {:ok, file_binary} = File.read(file_path)
    file_name = Path.basename(file_path)
    config = Application.fetch_env!(:skeptic_bot, :tigris_storage)
    bucket = Keyword.fetch!(config, :bucket)

    response =
      new()
      |> Req.put!(
        url: file_name,
        headers: [
          {"content-type", content_type},
          {"x-amz-acl", "public-read"}
        ],
        body: file_binary,
        receive_timeout: @timeout
      )

    case response do
      %Req.Response{status: status} when status in 200..299 ->
        public_url = "https://#{bucket}.fly.storage.tigris.dev/#{file_name}"
        {:ok, public_url}

      %Req.Response{status: status, body: body} ->
        Logger.error(
          "Failed to upload file to Tigris. Status: #{status}, Response: #{inspect(body)}"
        )

        {:error, "Failed to upload file. Status: #{status}"}
    end
  rescue
    e ->
      Logger.error("Error uploading file to Tigris: #{Exception.message(e)}")
      {:error, "Upload failed: #{Exception.message(e)}"}
  end

  @doc """
  Deletes a file from Tigris Storage.
  """
  def delete_file(file_name) do
    response =
      new()
      |> Req.delete!(
        url: file_name,
        receive_timeout: @timeout
      )

    case response do
      %Req.Response{status: status} when status in 200..299 ->
        :ok

      %Req.Response{status: status, body: body} ->
        Logger.error(
          "Failed to delete file from Tigris. Status: #{status}, Response: #{inspect(body)}"
        )

        {:error, "Failed to delete file. Status: #{status}"}
    end
  rescue
    e ->
      Logger.error("Error uploading file to Tigris: #{Exception.message(e)}")
      {:error, "Deletion failed: #{Exception.message(e)}"}
  end
end
