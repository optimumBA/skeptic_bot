# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :skeptic_bot,
  ecto_repos: [SkepticBot.Repo],
  generators: [binary_id: true, timestamp_type: :utc_datetime]

# Configures the endpoint
config :skeptic_bot, SkepticBotWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: SkepticBotWeb.ErrorHTML, json: SkepticBotWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: SkepticBot.PubSub,
  live_view: [signing_salt: "pFiPW2AF"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :skeptic_bot, SkepticBot.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  skeptic_bot: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  skeptic_bot: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :skeptic_bot, Oban,
  engine: Oban.Engines.Basic,
  queues: [],
  repo: SkepticBot.Repo

config :skeptic_bot, SkepticBot.Repo, types: SkepticBot.PostgrexTypes

# AppSignal
config :appsignal, :config,
  active: false,
  ecto_repos: [SkepticBot.Repo],
  env: config_env(),
  ignore_actions: ["SkepticBotWeb.HealthController#index"],
  name: "skeptic_bot",
  otp_app: :skeptic_bot

config :skeptic_bot, :downloading_runner,
  idle_shutdown_after: :timer.seconds(30),
  min: 0,
  max: 1,
  max_concurrency: 2,
  name: SkepticBot.DownloadingRunner,
  timeout: :timer.minutes(10)

config :skeptic_bot, :req_client_module, SkepticBot.ReqClient
config :skeptic_bot, :downloader_module, SkepticBot.Podcasts.DownloadingWorker
config :skeptic_bot, :transcription_module, SkepticBot.Transcription
config :skeptic_bot, :tigris_module, SkepticBot.Storage.Tigris
config :skeptic_bot, :rag_embedding_module, SkepticBot.Rag.Embedding
config :skeptic_bot, :mix_env, Mix.env()

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
