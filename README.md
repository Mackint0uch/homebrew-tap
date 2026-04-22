# Mackint0uch/homebrew-tap

Homebrew formulas for [ClauLock](https://claulock.com) — a local-first
secrets manager that lets AI coding agents **use** your API keys, tokens,
and SSH keys without ever **seeing** them.

## Install

```bash
brew install Mackint0uch/tap/claulock
clsec install
```

`clsec install` finishes the setup: starts the per-user daemon, registers
the MCP server with Claude Code, installs the hook that swaps
`{{SECRET_NAME}}` placeholders for real values at fork/exec time, and
stores your passphrase in the macOS Keychain or Linux Secret Service so
unlock is automatic after login.

## What you get

| Binary       | Purpose                                                     |
| ------------ | ----------------------------------------------------------- |
| `clsec`      | CLI — `clsec add`, `clsec list`, `clsec audit`, `clsec install`, etc. |
| `clsecd`     | Per-user daemon that holds the encrypted vault in memory.   |
| `clsec-mcp`  | MCP server Claude Code talks to over stdio.                 |
| `clsec-exec` | Exec shim that resolves `{{SECRET}}` placeholders in child processes. |

## Verification

Every release tarball downloaded by this formula is hash-pinned against
the SHA256 in `Formula/claulock.rb`. Homebrew verifies the hash before
unpacking. Upstream also publishes:

- A **minisign** signature over `SHA256SUMS` (pubkey [`minisign.pub`](https://github.com/Mackint0uch/ClauLock/blob/main/minisign.pub)).
- A **cosign** signature per binary (pubkey [`cosign.pub`](https://github.com/Mackint0uch/ClauLock/blob/main/cosign.pub)).
- **SLSA v1.0** provenance attesting the GitHub Actions build.

See the [verification guide](https://claulock.app/docs#verify) for the
exact commands.

## How this tap is updated

The [upstream release workflow](https://github.com/Mackint0uch/ClauLock/blob/main/.github/workflows/release.yml)
rebuilds `Formula/claulock.rb` on every tagged release (pulling real
SHA256s from `SHA256SUMS`), pushes a branch here, and opens a PR titled
`claulock <version>`. A maintainer merges after a smoke-test on a clean
machine.

Manual formula edits in this repo are rare by design — the source of
truth is [`packaging/homebrew/claulock.rb`](https://github.com/Mackint0uch/ClauLock/blob/main/packaging/homebrew/claulock.rb)
in the main repo. PRs that change the formula content (not just version
bumps) should land there first.

## Issues

Bug reports and feature requests belong upstream:
[github.com/Mackint0uch/ClauLock/issues](https://github.com/Mackint0uch/ClauLock/issues).

## License

Formula is dual-licensed MIT OR Apache-2.0, matching ClauLock itself.
