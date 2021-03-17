defmodule Telehashname.Mixfile do
  use Mix.Project

  def project do
    [
      app: :telehashname,
      version: "1.0.1",
      elixir: "~> 1.7",
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
      {:ex_doc, "~> 0.23", only: :dev},
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
