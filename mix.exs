defmodule Pilot.MixProject do
  use Mix.Project

  def project do
    [
      app: :pilot,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript(),
      description: "Interactive CLI/REPL for the NSAI ecosystem",
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Pilot.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # CLI and UI
      {:optimus, "~> 0.3"},
      {:owl, "~> 0.8"},
      {:table_rex, "~> 3.1"},

      # HTTP client
      {:req, "~> 0.4"},

      # Configuration
      {:yaml_elixir, "~> 2.9"},

      # JSON
      {:jason, "~> 1.4"},

      # Development and testing
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end

  defp escript do
    [
      main_module: Pilot.CLI,
      name: "pilot",
      comment: "NSAI Ecosystem CLI/REPL"
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/North-Shore-AI/pilot"}
    ]
  end
end
