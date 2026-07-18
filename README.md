# ColosseumCLI

Pre-built, self-contained `colo` deployment binaries — no source code, no .NET runtime required
on the target machine. This repo exists purely so a new worker machine can `git clone` and
deploy immediately instead of checking out the full `colosseum` source tree and building it.

Built from [colosseum/colosseum_cli](https://github.com/ej3muse/colosseum/tree/main/colosseum_cli)
via `colosseum_cli/release_binary.sh`. See `VERSION` in this repo for the exact source commit and
build time each release came from.

## Contents

- `dist/colo` — the `colo` CLI (self-contained, linux-x64, single file)
- `dist/colosseum-worker` — the per-agent execution-plane worker `colo deploy` launches
- `config/subjects.yaml` — versioned NATS subject/timeout config template `colo` needs as its
  anchor directory (it walks up from its own location looking for `config/subjects.yaml`)

Both binaries are fully self-contained: the .NET 8 runtime is bundled inside, so the target
machine needs nothing pre-installed beyond a Linux x86_64 userland (`sudo`, `useradd`, `sshd` for
interactive-CLI agents — same OS-level requirements as any `colo deploy`, just no `dotnet`).

## Install on a new machine

```bash
curl -fsSL https://raw.githubusercontent.com/ej3muse/ColosseumCLI/main/install.sh | bash
```

No path to pick, no build step. Same shape as the Claude Code / Codex CLI installers: it clones
into a fixed, tool-owned location (`$XDG_DATA_HOME/colosseum-cli`, i.e. `~/.local/share/colosseum-cli`
by default), symlinks `colo` onto `~/.local/bin`, and adds that to your shell's PATH if it isn't
already there. Override the install location with `COLOSSEUM_CLI_INSTALL_DIR=/some/path` before
running the installer if you ever need to.

**If `~/.local/bin` wasn't already on your PATH**, the installer prints a warning to that effect
and cannot fix your *current* shell (it runs as a child of `curl | bash` — a subprocess can't
change its parent's environment). Do exactly what it tells you: either open a new terminal, or
run the `source ...` command it prints, **before** running `colo deploy`. Chaining `colo deploy`
straight onto the same line as the install one-liner will silently fail with "command not found"
the first time, on any machine where `~/.local/bin` wasn't already on PATH.

Prefer to manage the checkout yourself instead? Clone this repo anywhere — `colo` finds its own
config by walking up from wherever the executable lives (looking for `config/subjects.yaml`), so
any location works as long as `dist/` and `config/` stay together as shipped:

```bash
git clone https://github.com/ej3muse/ColosseumCLI.git <wherever-you-want>
ln -sf <wherever-you-want>/dist/colo ~/.local/bin/colo
```

## Updating

Re-run the installer — it's safe to re-run, it just fast-forwards to the latest release. Since
`colo` is already on PATH from the first install, updates don't hit the new-shell issue above:

```bash
curl -fsSL https://raw.githubusercontent.com/ej3muse/ColosseumCLI/main/install.sh | bash
colo deploy
```
