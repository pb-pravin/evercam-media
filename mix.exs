defmodule Media.Mixfile do
  use Mix.Project

  def project do
    [app: :media,
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
    [mod: {Media, []},
     applications: app_list(Mix.env)]
  end

  defp app_list(:dev), do: [:dotenv | app_list]
  defp app_list(_), do: app_list
  defp app_list, do: [:phoenix, :cowboy, :logger, :dotenv, :httpotion, :timex]

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
     {:timex, "~> 0.13.3"},
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
