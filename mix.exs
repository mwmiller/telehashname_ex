defmodule Telehashname.Mixfile do
  use Mix.Project

  def project do
    [app: :telehashname,
     version: "0.0.2",
     elixir: "~> 1.2",
     name: "Telehashname",
     source_url: "https://github.com/mwmiller/telehashname_ex",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps,
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:earmark, "~>= 0.2", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev},
      {:power_assert, "~> 0.0.8", only: :test},
    ]
  end

  defp description do
    """
    Telehash hashname implementation
    """
  end

  defp package do
    [
     files: ["lib", "mix.exs", "README*", "LICENSE*", ],
     maintainers: ["Matt Miller"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/mwmiller/telehashname_ex",}
    ]
  end

end
