defmodule EvercamMedia.Mixfile do
  use Mix.Project

  def project do
    [app: :evercam_media,
     version: get_version,
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
    :uuid
  ]

  defp deps do
    [{:phoenix, "~> 0.13"},
     {:phoenix_ecto, "~> 0.4"},
     {:phoenix_html, "~> 1.0"},
     {:phoenix_live_reload, "~> 0.4", only: :dev},
     {:postgrex, ">= 0.0.0"},
     {:ecto, "~> 0.11.2"},
     {:cowboy, "~> 1.0"},
     {:con_cache, "~> 0.6.0"},
     {:httpotion, github: "myfreeweb/httpotion"},
     {:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.1.1", override: true},
     {:dotenv, "~> 0.0.4"},
     {:timex, "~> 0.13.3"},
     {:porcelain, "~> 2.0"},
     {:mini_s3, github: "ericmj/mini_s3", branch: "hex-fixes"},
     {:erlcloud, github: 'gleber/erlcloud'},
     {:exq, github: "akira/exq"},
     {:eredis, github: 'wooga/eredis', tag: 'v1.0.5', override: true},
     {:uuid, github: 'zyro/elixir-uuid', override: true},
     {:exrm, "~> 0.14.16"}]
  end

  defp get_version do
    version = :os.cmd('git describe --always --tags')
    |> List.to_string
    |> String.strip(?\n)
    |> String.split("-")

    case version do
      [tag] -> tag
      [tag, _commits_since_tag, commit] -> "#{tag}-#{commit}"
    end
  end
end
