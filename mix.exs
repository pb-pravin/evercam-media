defmodule Media.Mixfile do
  use Mix.Project

  def project do
    [app: :media,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: ["lib", "web"],
     compilers: [:phoenix] ++ Mix.compilers,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {Media, []},
     applications: [:phoenix, :cowboy, :logger, :dotenv, :httpotion]]
  end

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, "~> 0.10.0"},
     {:phoenix_ecto, "~> 0.1"},
     {:postgrex, ">= 0.0.0"},
     {:cowboy, "~> 1.0"},
     {:httpotion, "~> 1.0.0"},
     {:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.1.1"},
     {:dotenv, "~> 0.0.4"},
     {:timex, "~> 0.13.3"}]
  end
end
