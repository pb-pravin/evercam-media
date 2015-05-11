# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :evercam_media, EvercamMedia.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "joIg696gDBw3ZjdFTkuWNz7s21nXrcRUkZn3Lsdp7pCNodzCMl/KymikuJVw0igG",
  debug_errors: false,
  server: true,
  root: Path.expand("..", __DIR__),
  pubsub: [name: EvercamMedia.PubSub,
           adapter: Phoenix.PubSub.PG2],
  code_reloader: true,
  live_reload: [
    url: "ws://localhost:4000",
    patterns: [~r{priv/static/.*(js|css|png|jpeg|jpg|gif)$},
               ~r{web/views/.*(ex)$},
               ~r{web/templates/.*(eex)$}]]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :exq,
  host: '127.0.0.1',
  port: 6379,
  namespace: "sidekiq",
  queues: ["to_elixir"]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
