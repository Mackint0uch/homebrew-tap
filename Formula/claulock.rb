class Claulock < Formula
  desc "Local-first secrets manager for AI coding agents — use secrets without revealing them"
  homepage "https://claulock.com"
  version "0.1.0"
  license any_of: ["MIT", "Apache-2.0"]

  # This file is the source-of-truth template. `packaging/homebrew/update-formula.sh`
  # rewrites the `version`, `url`, and `sha256` fields at release time and opens a
  # pull request in the tap repository (Mackint0uch/homebrew-tap).
  #
  # Until the first tag exists, the url/sha256 values below are placeholders and
  # will 404 if anyone tries `brew install`. That's intentional: it keeps the
  # formula committed alongside the code without pretending a release exists.

  on_macos do
    on_arm do
      url "https://github.com/Mackint0uch/ClauLock/releases/download/v0.1.0/claulock-v0.1.0-macos-arm64.tar.gz"
      sha256 "cb0f817b5b10a56b79a91619969fdc8289e3d8e3d1c667df821c9b82abb18a28"
    end
    on_intel do
      url "https://github.com/Mackint0uch/ClauLock/releases/download/v0.1.0/claulock-v0.1.0-macos-x86_64.tar.gz"
      sha256 "e7dc4169cc0a5ec95e78b8699793f10e17b914470303985d33a4b8801f68f832"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Mackint0uch/ClauLock/releases/download/v0.1.0/claulock-v0.1.0-linux-arm64.tar.gz"
      sha256 "2bb9caeeffa8a2ed90e951965feae1b1127d089043075715f042848ff258349e"
    end
    on_intel do
      url "https://github.com/Mackint0uch/ClauLock/releases/download/v0.1.0/claulock-v0.1.0-linux-x86_64.tar.gz"
      sha256 "6cc44c51329037adb1b10596c77f02eb59a849e8565a5306b196159b61b6ed86"
    end
  end

  def install
    bin.install "clsec", "clsecd", "clsec-mcp", "clsec-exec"
    doc.install "README.md" if File.exist?("README.md")
    %w[LICENSE-MIT LICENSE-APACHE].each do |f|
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
      Issues: https://github.com/Mackint0uch/ClauLock/issues
    EOS
  end

  test do
    assert_match "clsec", shell_output("#{bin}/clsec --help")
    assert_match version.to_s, shell_output("#{bin}/clsec --version")
  end
end
