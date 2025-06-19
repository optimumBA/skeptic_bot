defmodule SkepticBot.HttpClient do
  @moduledoc false

  alias SkepticBot.ReqHttpClient

  @type reason :: String.t()
  @type response :: %Req.Response{}
  @type url :: String.t()

  @callback make_request(url()) ::
              {:ok, response()} | {:error, reason()}

  @spec make_request(url()) ::
          {:ok, response()} | {:error, reason()}
  def make_request(url), do: impl().make_request(url)

  defp impl, do: Application.get_env(:skeptic_bot, :http_client, ReqHttpClient)
end
