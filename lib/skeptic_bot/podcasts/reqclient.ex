defmodule SkepticBot.ReqClient do
  @moduledoc false

  @type req :: %Req.Response{}

  @callback make_request(String.t()) ::
              {:ok, req()} | {:error, String.t()}
  @spec make_request(String.t()) ::
          {:ok, req()} | {:error, String.t()}
  def make_request(url), do: Req.get(url)
end
