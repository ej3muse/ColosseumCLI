#!/usr/bin/env bash
# One-line installer for the ColosseumCLI binary-only distribution repo (self-contained colo +
# colosseum-worker, no source, no .NET runtime needed). Mirrors the Claude Code / Codex CLI
# installer shape: no path to pick, no build step — clone into a fixed, tool-owned location under
# XDG_DATA_HOME and symlink the entry point onto PATH.
#
#   curl -fsSL https://raw.githubusercontent.com/ej3muse/ColosseumCLI/main/install.sh | bash
#
# Safe to re-run: re-running just fast-forwards the existing checkout to the latest release.
set -euo pipefail

REPO_URL="https://github.com/ej3muse/ColosseumCLI.git"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
INSTALL_DIR="${COLOSSEUM_CLI_INSTALL_DIR:-$DATA_HOME/colosseum-cli}"
BIN_DIR="$HOME/.local/bin"

echo "== Installing colo to $INSTALL_DIR =="

if [ -d "$INSTALL_DIR/.git" ]; then
    git -C "$INSTALL_DIR" fetch --depth 1 origin main
    git -C "$INSTALL_DIR" reset --hard origin/main
else
    rm -rf "$INSTALL_DIR"
    git clone --depth 1 "$REPO_URL" "$INSTALL_DIR"
fi

mkdir -p "$BIN_DIR"
ln -sf "$INSTALL_DIR/dist/colo" "$BIN_DIR/colo"
chmod +x "$INSTALL_DIR/dist/colo" "$INSTALL_DIR/dist/colosseum-worker"

echo "✓ colo -> $BIN_DIR/colo -> $INSTALL_DIR/dist/colo"

case ":$PATH:" in
    *":$BIN_DIR:"*)
        echo ""
        echo "接下來執行：colo deploy"
        ;;
    *)
        SHELL_RC="$HOME/.bashrc"
        case "$(basename "${SHELL:-bash}")" in
            zsh) SHELL_RC="$HOME/.zshrc" ;;
        esac
        if ! grep -qs "# colosseum-cli PATH" "$SHELL_RC" 2>/dev/null; then
            printf '\n# colosseum-cli PATH\nexport PATH="%s:$PATH"\n' "$BIN_DIR" >> "$SHELL_RC"
        fi
        # This script runs via `curl | bash`, a *child* shell — `export PATH` here cannot reach
        # back into the shell the user actually typed the command in, no matter how it's worded.
        # Piping straight into `colo deploy` afterwards is exactly the trap that broke someone
        # before this comment existed: it silently ran the still-stale-PATH parent shell's
        # (missing) `colo`. Never soften this into an aside they can skim past.
        echo ""
        echo "⚠ 這一步是在子 shell 裡跑的（curl | bash），PATH 的變更不會回到你目前這個終端機。"
        echo "  現在你目前的 shell 還是找不到 colo，必須先做以下兩者之一，再執行 colo deploy："
        echo ""
        echo "    source $SHELL_RC && colo deploy"
        echo ""
        echo "  或者：開一個新的終端機，再執行 colo deploy。"
        ;;
esac
