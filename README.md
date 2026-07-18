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
git clone https://github.com/ej3muse/ColosseumCLI.git ~/projects/ColosseumCLI
mkdir -p ~/.local/bin
ln -sf ~/projects/ColosseumCLI/dist/colo ~/.local/bin/colo
# ensure ~/.local/bin is on PATH, then:
colo deploy
```

## Updating

Pull the latest commit here whenever a new release lands — no rebuild step needed, the binaries
are already built:

```bash
cd ~/projects/ColosseumCLI && git pull
colo deploy
```

## Releasing a new version (from the `colosseum` source repo)

```bash
cd ~/projects/colosseum/colosseum_cli
./release_binary.sh                       # publishes + commits + pushes here
./release_binary.sh /path/to/ColosseumCLI  # or an explicit checkout path
```
