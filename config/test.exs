use Mix.Config

config :evercam_media,
  skip_camera_workers: true

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :evercam_media, EvercamMedia.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :evercam_media, EvercamMedia.Repo,
  adapter: Ecto.Adapters.Postgres,
  extensions: [{EvercamMedia.Types.JSON.Extension, library: Poison}],
  username: "postgres",
  password: "postgres",
  database: System.get_env["db"] || "evercam_dev"
