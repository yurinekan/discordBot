defmodule Jacquin.MixProject do
  use Mix.Project

  def project do
    [
      app: :jacquin,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Jacquin.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nostrum, git: "https://github.com/Kraigie/nostrum.git"},
      {:httpoison, "~> 1.8"},
      {:poison, "~> 5.0"}
    ]
  end
end
