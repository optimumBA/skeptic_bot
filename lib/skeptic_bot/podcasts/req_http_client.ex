defmodule SkepticBot.Podcasts.ReqHttpClient do
  @moduledoc false

  alias SkepticBot.Podcasts.HttpClient

  @behaviour HttpClient

  @impl HttpClient
  def make_request(url), do: Req.get(url)
end
