class Claulock < Formula
  desc "Local-first secrets manager for AI coding agents"
  homepage "https://claulock.com"
  version "0.9.0"
  # Tri-layer licensing per upstream NOTICE: Apache-2.0 covers crypto + hooks
  # + leak_test; BUSL-1.1 covers product code (CLI, daemon, exec, scrubber,
  # keystore, MCP, IPC, UI, site, packaging). BUSL converts to Apache-2.0
  # on 2030-05-01.
  license any_of: ["Apache-2.0", "BUSL-1.1"]

  # This file is the source-of-truth template. `packaging/homebrew/update-formula.sh`
  # rewrites the `version`, `url`, and `sha256` fields at release time and opens a
  # pull request in the tap repository (Mackint0uch/homebrew-tap).
  #
  # Until the first tag exists, the url/sha256 values below are placeholders and
  # will 404 if anyone tries `brew install`. That's intentional: it keeps the
  # formula committed alongside the code without pretending a release exists.

  on_macos do
    on_arm do
      url "https://github.com/Mackint0uch/claulock-releases/releases/download/v0.9.0/claulock-v0.9.0-macos-arm64.tar.gz"
      sha256 "cc973379eab269ee06f8d548925365bbb10cf9a91762737eb538ba51cfe2e86f"
    end
    on_intel do
      url "https://github.com/Mackint0uch/claulock-releases/releases/download/v0.9.0/claulock-v0.9.0-macos-x86_64.tar.gz"
      sha256 "e2eb35df37bee2fa8bb05f806ae6bf05fac7467576b1186d2be142a7f28e8652"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Mackint0uch/claulock-releases/releases/download/v0.9.0/claulock-v0.9.0-linux-arm64.tar.gz"
      sha256 "7cdee552c2c7eaf37501f2701dce2d254a2052ff608b1fd33b303a55fdcc557f"
    end
    on_intel do
      url "https://github.com/Mackint0uch/claulock-releases/releases/download/v0.9.0/claulock-v0.9.0-linux-x86_64.tar.gz"
      sha256 "f2a5d2a46dd22d1f473812836b374414e1739d18177b6fc056b95695ff15fbc7"
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

      Docs:  https://claulock.com/docs
      Issues: https://github.com/Mackint0uch/claulock-releases/issues
    EOS
  end

  test do
    assert_match "clsec", shell_output("#{bin}/clsec --help")
    assert_match version.to_s, shell_output("#{bin}/clsec --version")
  end
end
