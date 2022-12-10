defmodule Mt940.Mixfile do
  use Mix.Project

  def project do
    [
      app: :mt940,
      version: "1.1.4",
      elixir: "~> 1.9",
      description: "MT940/MT942 parser for Elixir.",
      package: package(),
      deps: deps(),
      name: "MT940/MT942 Parser",
      source_url: "https://github.com/my-flow/mt940"
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:decimal, "~> 2.0.0"},
      {:ex_doc, "~> 0.20.2", only: :dev},
      {:timex, "~> 3.6.1"},
      {:exjsx, "~> 4.0.0", only: :test},
    ]
  end

  defp package do
    [
      files:       ["lib", "priv", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Florian J. Breunig"],
      licenses:    ["MIT"],
      links:       %{"GitHub" => "https://github.com/my-flow/mt940"}
    ]
  end
end
