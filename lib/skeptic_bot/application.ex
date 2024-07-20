defmodule SkepticBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SkepticBotWeb.Telemetry,
      SkepticBot.Repo,
      {DNSCluster, query: Application.get_env(:skeptic_bot, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SkepticBot.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: SkepticBot.Finch},
      # Start a worker by calling: SkepticBot.Worker.start_link(arg)
      # {SkepticBot.Worker, arg},
      {Nx.Serving, name: SkepticBot.Rag.Embedding, serving: SkepticBot.Rag.Embedding.serving()},
      {Nx.Serving, name: SkepticBot.Transcription, serving: SkepticBot.Transcription.serving()},
      # Start to serve requests, typically the last entry
      SkepticBotWeb.Endpoint,
      {Oban, Application.fetch_env!(:skeptic_bot, Oban)}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SkepticBot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SkepticBotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
