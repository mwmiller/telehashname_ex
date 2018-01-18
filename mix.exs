defmodule Telehashname.Mixfile do
  use Mix.Project

  def project do
    [
      app: :telehashname,
      version: "1.0.0",
      elixir: "~> 1.4",
      name: "Telehashname",
      source_url: "https://github.com/mwmiller/telehashname_ex",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:earmark, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.14", only: :dev},
      {:credo, "~> 0.8", only: [:dev, :test]}
    ]
  end

  defp description do
    """
    Telehash hashname implementation
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Matt Miller"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mwmiller/telehashname_ex"}
    ]
  end
end
