defmodule SkepticBot.ReqHttpClient do
  @moduledoc false

  alias SkepticBot.HttpClient

  @behaviour HttpClient

  @impl HttpClient
  def make_request(url), do: Req.get(url)
end
