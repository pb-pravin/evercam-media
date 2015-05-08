defmodule EvercamMedia.Mixfile do
  use Mix.Project

  def project do
    [app: :evercam_media,
     version: get_version,
     elixir: "~> 1.0",
     elixirc_paths: ["lib", "web"],
     compilers: [:phoenix] ++ Mix.compilers,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {EvercamMedia, []},
     applications: app_list(Mix.env)]
  end

  defp app_list(:dev), do: [:dotenv | app_list]
  defp app_list(_), do: app_list
  defp app_list, do: [
    :cowboy,
    :ecto,
    :eredis,
    :exq,
    :httpotion,
    :logger,
    :phoenix,
    :porcelain,
    :postgrex,
    :timex,
    :uuid
  ]

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, "~> 0.11.0"},
     {:phoenix_ecto, "~> 0.3"},
     {:postgrex, ">= 0.0.0"},
     {:ecto, "~> 0.11.2"},
     {:cowboy, "~> 1.0"},
     {:httpotion, github: "myfreeweb/httpotion"},
     {:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.1.1", override: true},
     {:dotenv, "~> 0.0.4"},
     {:timex, "~> 0.13.3"},
     {:porcelain, "~> 2.0"},
     {:mini_s3, github: "ericmj/mini_s3", branch: "hex-fixes"},
     {:erlcloud, github: 'gleber/erlcloud'},
     {:exq, github: "akira/exq"},
     {:eredis, github: 'wooga/eredis', tag: 'v1.0.5'},
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
