defmodule LvStates.MixProject do
  use Mix.Project

  def project do
    [
      app: :lv_states,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # Docs
      name: "lv-states",
      source_url: "https://github.com/git-toni/lv-states",
      homepage_url: "https://github.com/git-toni/lv-states",
      docs: [
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:phoenix_live_view, "~> 0.15.1"},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end
  defp package do
    [
      maintainers: ["Toni Urcola"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/git-toni/lv-states"}
    ]
  end
end
