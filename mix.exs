defmodule KioskSystemx8664.Mixfile do
  use Mix.Project

  @app :kiosk_system_x86_64
  @version Path.join(__DIR__, "VERSION")
    |> File.read!
    |> String.trim

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.8",
      compilers: Mix.compilers ++ [:nerves_package],
      nerves_package: nerves_package(),
      description: description(),
      package: package(),
      deps: deps(),
      aliases: [loadconfig: [&bootstrap/1]],
      docs: [extras: ["README.md"], main: "readme"]
    ]
  end

  def application do
    []
  end

  defp bootstrap(args) do
    set_target()
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  defp nerves_package do
    [
      type: :system,
      artifact_sites: [
        {:github_releases, "letoteteam/#{@app}"}
      ],
      build_runner_opts: build_runner_opts(),
      platform: Nerves.System.BR,
      platform_config: [
        defconfig: "nerves_defconfig"
      ],
      checksum: package_files()
    ]
  end

  defp deps do
    [
      {:nerves, "~> 1.5.0", runtime: false},
      {:nerves_system_br, "1.10.2", runtime: false},
      {:nerves_toolchain_x86_64_unknown_linux_gnu , "1.2.0", runtime: false},
      {:nerves_system_linter, "~> 0.3.0", runtime: false},
      {:ex_doc, "~> 0.18", only: :dev}
    ]
  end

  defp description do
    """
    Nerves System - x86_64 Kiosk
    """
  end

  defp package do
    [
      files: package_files(),
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/letoteteam/#{@app}"}
    ]
  end

  defp package_files do
    [
      "fwup_include",
      "lib",
      "patches",
      "priv",
      "rootfs_overlay",
      "CHANGELOG.md",
      "Config.in",
      "fwup-revert.conf",
      "fwup.conf",
      "grub.cfg",
      "LICENSE",
      "linux-4.19.defconfig",
      "logo_custom_clut224.ppm",
      "mix.exs",
      "nerves_defconfig",
      "post-build.sh",
      "post-createfs.sh",
      "README.md",
      "users_table.txt",
      "VERSION"
    ]
  end

  defp build_runner_opts() do
    if primary_site = System.get_env("BR2_PRIMARY_SITE") do
      [make_args: ["BR2_PRIMARY_SITE=#{primary_site}", "PARALLEL_JOBS=8"]]
    else
      [make_args: ["PARALLEL_JOBS=8"]]
    end
  end

  defp set_target() do
    if function_exported?(Mix, :target, 1) do
      apply(Mix, :target, [:target])
    else
      System.put_env("MIX_TARGET", "target")
    end
  end
end
