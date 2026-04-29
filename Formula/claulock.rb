class Claulock < Formula
  desc "Local-first secrets manager for AI coding agents"
  homepage "https://claulock.com"
  version "0.2.1"
  # Tri-layer licensing per upstream NOTICE: Apache-2.0 covers crypto + hooks
  # + leak_test; BUSL-1.1 covers product code (CLI, daemon, exec, scrubber,
  # keystore, MCP, IPC, UI, site, packaging). BUSL converts to Apache-2.0
  # on 2030-05-01.
  license any_of: ["Apache-2.0", "BUSL-1.1"]

  # This file is the source-of-truth template. `packaging/homebrew/update-formula.sh`
  # rewrites the `version`, `url`, and `sha256` fields at release time and opens a
  # pull request in the tap repository (Mackint0uch/homebrew-tap).

  on_macos do
    on_arm do
      url "https://github.com/Mackint0uch/claulock-releases/releases/download/v0.2.1/claulock-v0.2.1-macos-arm64.tar.gz"
      sha256 "a1d34e148e4d31577ba09a549754e1d406e1c999c673be17578427d5a889b832"
    end
    on_intel do
      url "https://github.com/Mackint0uch/claulock-releases/releases/download/v0.2.1/claulock-v0.2.1-macos-x86_64.tar.gz"
      sha256 "717e64e1b742a230e3438e2b6722de09284423387fa9e762cbe62b7913879335"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Mackint0uch/claulock-releases/releases/download/v0.2.1/claulock-v0.2.1-linux-arm64.tar.gz"
      sha256 "b2893cc1be24b7b6aeb950ded14b7ab50508d4bd4546c4ee297511b597520ae0"
    end
    on_intel do
      url "https://github.com/Mackint0uch/claulock-releases/releases/download/v0.2.1/claulock-v0.2.1-linux-x86_64.tar.gz"
      sha256 "a6e341e3ccf47e8fd037d5e5bf5c87eaa740d87c0f833d03d2c8946c5e0eae03"
    end
  end

  def install
    # clsec-scrub is required by `clsec install` and the PostToolUse hook;
    # v0.1.0 tarballs are MISSING it (bug — patched in v0.1.1+). The line
    # below uses File.exist? to install whatever the tarball actually ships
    # without breaking on legacy v0.1.0 tarballs that lack clsec-scrub.
    %w[clsec clsecd clsec-mcp clsec-exec clsec-scrub].each do |b|
      bin.install b if File.exist?(b)
    end
    doc.install "README.md" if File.exist?("README.md")
    # Install whatever license files the tarball ships. v0.1.0 carries the
    # legacy LICENSE-MIT (predates the v0.1.0 license restructure); newer
    # releases ship LICENSE-APACHE + LICENSE-BSL + NOTICE.
    %w[LICENSE-MIT LICENSE-APACHE LICENSE-BSL NOTICE].each do |f|
      (pkgshare/"licenses").install f if File.exist?(f)
    end
  end

  service do
    run [opt_bin/"clsecd"]
    keep_alive true
    log_path var/"log/claulock/daemon.log"
    error_log_path var/"log/claulock/daemon.log"
    environment_variables PATH: "#{HOMEBREW_PREFIX}/bin:/usr/bin:/bin"
  end

  def caveats
    <<~EOS
      ClauLock is installed. To finish setup:

        clsec install

      That command wires up the Claude Code plugin, starts the user daemon,
      and stores your passphrase in the macOS Keychain (or secret-service on
      Linux) so unlock is automatic after login.

      Homebrew's service can run the daemon standalone if you prefer:
        brew services start claulock

      v0.2.0 adds optional cross-device sync (E2EE):
        clsec pair init   # enroll a second device
        clsec sync now    # one-shot sync

      Docs:  https://claulock.com/docs
      Issues: https://github.com/Mackint0uch/ClauLock/issues
    EOS
  end

  test do
    assert_match "clsec", shell_output("#{bin}/clsec --help")
    assert_match version.to_s, shell_output("#{bin}/clsec --version")
  end
end
