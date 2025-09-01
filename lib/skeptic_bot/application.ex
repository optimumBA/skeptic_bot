defmodule SkepticBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl Application
  def start(_type, _args) do
    children =
      children(
        always: SkepticBotWeb.Telemetry,
        parent: SkepticBot.Repo,
        parent:
          {DNSCluster, query: Application.get_env(:skeptic_bot, :dns_cluster_query) || :ignore},
        parent: {Phoenix.PubSub, name: SkepticBot.PubSub},
        # Start the Finch HTTP client for sending emails
        parent: {Finch, name: SkepticBot.Finch},
        # Start a worker by calling: SkepticBot.Worker.start_link(arg)
        # {SkepticBot.Worker, arg},
        parent: {Registry, keys: :unique, name: SkepticBot.PredictionRegistry},
        # Start to serve requests, typically the last entry
        parent: SkepticBotWeb.Endpoint,
        parent: SkepticBot.PredictionHandler,
        parent: SkepticBot.WebhookHandler,
        parent: {FLAME.Pool, Application.fetch_env!(:skeptic_bot, :downloading_runner)},
        parent: {Oban, Application.fetch_env!(:skeptic_bot, Oban)}
      )

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SkepticBot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl Application
  def config_change(changed, _new, removed) do
    SkepticBotWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp children(child_specs) do
    is_parent? = is_nil(FLAME.Parent.get())
    is_flame? = !is_parent? || FLAME.Backend.impl() == FLAME.LocalBackend

    Enum.flat_map(child_specs, fn
      {:always, spec} -> [spec]
      {:parent, spec} when is_parent? == true -> [spec]
      {:parent, _spec} when is_parent? == false -> []
      {:flame, spec} when is_flame? == true -> [spec]
      {:flame, _spec} when is_flame? == false -> []
    end)
  end
end
