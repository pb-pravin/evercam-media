defmodule EvercamMedia.Mixfile do
  use Mix.Project

  def project do
    [app: :evercam_media,
     version: "1.0.0",
     elixir: "~> 1.0",
     elixirc_paths: ["lib", "web"],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     compilers: [:phoenix] ++ Mix.compilers,
     deps: deps]
  end

  def application do
    [mod: {EvercamMedia, []},
     applications: app_list(Mix.env)]
  end

  defp app_list(:dev), do: [:dotenv | app_list]
  defp app_list(_), do: app_list
  defp app_list, do: [
    :con_cache,
    :cowboy,
    :ecto,
    :erlcloud,
    :eredis,
    :exq,
    :httpotion,
    :inets,
    :logger,
    :mini_s3,
    :phoenix,
    :porcelain,
    :postgrex,
    :timex,
    :calendar,
    :uuid
  ]

  defp deps do
    [
		 {:phoenix, "~> 0.15"},
     {:phoenix_ecto, "~> 0.8"},
     {:phoenix_html, "~> 1.4"},
     {:phoenix_live_reload, "~> 0.5", only: :dev},
     {:postgrex, ">= 0.0.0"},
     {:ecto, "~> 0.14"},
     {:cowboy, "~> 1.0"},
     {:con_cache, "~> 0.6.0"},
     {:httpotion, github: "myfreeweb/httpotion"},
     {:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.1.1", override: true},
     {:dotenv, "~> 0.0.4"},
     {:calendar, "~> 0.8.0"},
     {:timex, "~> 0.13.3"},
     {:porcelain, "~> 2.0"},
     {:mini_s3, github: "ericmj/mini_s3", branch: "hex-fixes"},
     {:erlcloud, github: 'gleber/erlcloud'},
     {:exq, github: "akira/exq"},
     {:eredis, github: 'wooga/eredis', tag: 'v1.0.5', override: true},
     {:uuid, github: 'zyro/elixir-uuid', override: true},
     {:exrm, "~> 0.14.16"}]
  end
end
