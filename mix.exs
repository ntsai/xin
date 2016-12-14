defmodule Xin.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :xin,
     version: @version,
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     name: "Xin",
     docs: [extras: ["README.md"], main: "Xin"],
     deps: deps,
     package: package,
     description: """
     An Phoenix Test Package.
     """
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :ecto_timestamps, :qiniu]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
     {:phoenix, "~> 1.2.1"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_ecto, "~> 3.0"},
     {:httpoison, "~> 0.8.3"},
     {:qiniu, github: "tony612/qiniu"},
     {:joken, "~> 1.2"},
     {:xlsxir, "~> 1.3.1"},
     {:elixlsx, "~> 0.0.6"},
     {:ecto_timestamps, "~> 1.0.0"},
     {:ex_doc, "~> 0.14", only: :dev},
    ]
  end

  defp package do
    [maintainers: ["sai",],
     licenses: ["MIT"],
     links: %{github: "https://github.com/ntsai/xin"},
     files: ~w(lib README.md mix.exs LICENSE)]
  end
end
