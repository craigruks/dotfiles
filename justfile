# Dotfiles repo tasks - run `just` (no args) to list them.
#
# Recipes self-locate to the checkout you invoke them from (main OR a git
# worktree) via justfile_directory(), so `just test …` inside a worktree tests
# THAT branch's config. `apply` / `rollback` deliberately act on the main tree
# only, so a stray invocation in a worktree can't repoint your live symlinks.

wt   := justfile_directory()            # the checkout this justfile lives in
main := env_var('HOME') / ".dotfiles"   # the live tree stow's symlinks point at

# List all recipes
default:
    @just --list

# Isolated "dot env" test of THIS checkout - throwaway state, live config untouched
test tool:
    #!/usr/bin/env bash
    # tool: tmux | nvim | zsh | ghostty | nix. Launches the tool reading this
    # worktree's config with temp XDG data/state dirs, so your live config, nvim
    # plugins, and shell history are never touched. Close it - nothing to revert.
    set -euo pipefail
    wt='{{wt}}'
    scratch="$(mktemp -d)"; trap 'rm -rf "$scratch"' EXIT
    export XDG_CONFIG_HOME="$wt/.config" XDG_DATA_HOME="$scratch" XDG_STATE_HOME="$scratch"
    case '{{tool}}' in
      tmux)    tmux -L dottest -f "$wt/.config/tmux/tmux.conf" ;;
      nvim)    nvim ;;
      zsh)     ZDOTDIR="$wt" zsh -i ;;
      ghostty) "/Applications/Ghostty.app/Contents/MacOS/ghostty" ;;
      nix)     darwin-rebuild build --flake "$wt/.config/nix#default" ;;
      *)       echo "usage: just test <tmux|nvim|zsh|ghostty|nix>" >&2; exit 2 ;;
    esac

# Preflight checks - run before committing.
check:
    #!/usr/bin/env bash
    set -euo pipefail
    cd '{{wt}}'
    echo '==> zsh -n .zshrc';        zsh -n .zshrc
    echo '==> bash -n .local/bin/*'; for f in .local/bin/*; do bash -n "$f"; done
    if command -v stylua   >/dev/null; then echo '==> stylua --check'; stylua --check .config/nvim; else echo '(stylua not installed - skipped)'; fi
    if command -v gitleaks >/dev/null; then echo '==> gitleaks';       gitleaks detect --no-banner --redact; else echo '(gitleaks not installed - skipped)'; fi
    echo ok

# App-level refresh without a full rebuild: sync nvim plugins + reload tmux.
sync:
    #!/usr/bin/env bash
    set -euo pipefail
    if command -v nvim >/dev/null; then echo '==> nvim Lazy sync'; nvim --headless '+Lazy! sync' +qa; fi
    if tmux info >/dev/null 2>&1;   then echo '==> tmux reload';    tmux source-file "$HOME/.config/tmux/tmux.conf"; fi

# Make the MAIN tree live: restow symlinks + refresh (merge your branch first)
apply:
    #!/usr/bin/env bash
    # Always targets ~/.dotfiles so a stray run inside a worktree can't repoint
    # your live symlinks at an ephemeral checkout.
    set -euo pipefail
    [ '{{wt}}' = '{{main}}' ] || echo 'note: applying MAIN ({{main}}), not this worktree - merge your branch first' >&2
    cd '{{main}}'
    echo '==> stow --restow .'; stow --restow --target "$HOME" .
    just sync

# Revert the live config to a git ref (branch / tag / sha), then restow.
rollback ref:
    #!/usr/bin/env bash
    set -euo pipefail
    cd '{{main}}'
    git checkout '{{ref}}'
    stow --restow --target "$HOME" .
    just sync

# Post-nix fresh-machine setup - run AFTER `darwin-rebuild switch`. Idempotent.
setup:
    #!/usr/bin/env bash
    set -euo pipefail
    cd '{{main}}'
    echo '==> stow .';        stow --target "$HOME" .
    echo '==> arm git hooks'; git config core.hooksPath .githooks
    echo '==> bootstrap tpm'; [ -d "$HOME/.config/tmux/plugins/tpm" ] || git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
    echo 'done - open tmux and press <prefix>+I to install plugins; run :Lazy sync in nvim'
    echo 'next: seed the 1Password service-account token (see .zshrc), then `just ssh-config`'

# One-time private-overlay scaffold (casks/brews kept out of the public repo).
# Optional; skip it and the public flake builds directly. See README "Private apps".
private-init:
    #!/usr/bin/env bash
    set -euo pipefail
    dir="$HOME/.nix-private"
    if [ -e "$dir/flake.nix" ]; then
      echo "$dir/flake.nix already exists - leaving it alone"
    else
      mkdir -p "$dir"
      cat > "$dir/flake.nix" <<EOF
    {
      # Machine-local private overlay. NEVER in git - lives at ~/.nix-private,
      # symlinked from /etc/nix-darwin. See the dotfiles README, "Private apps".
      description = "machine-local private overlay for the dotfiles darwin config";

      # git+file uses TRACKED files of the live tree (dirty working copy included).
      # \`just rebuild\` relocks this every run so it always follows the repo.
      inputs.dotfiles.url = "git+file://$HOME/.dotfiles?dir=.config/nix";

      outputs = { self, dotfiles }: {
        darwinConfigurations.default =
          dotfiles.inputs.nix-darwin.lib.darwinSystem {
            modules = [
              dotfiles.darwinModules.default
              {
                # Private extras only - merged into the public lists.
                homebrew.casks = [ ];
                homebrew.brews = [ ];
              }
            ];
          };
      };
    }
    EOF
    fi
    echo '==> symlink /etc/nix-darwin (needs sudo)'
    sudo ln -sfn "$dir" /etc/nix-darwin
    ( cd "$dir" && nix flake lock --allow-dirty-locks )
    echo "done - add private casks/brews to $dir/flake.nix, then \`just rebuild\`"

# The file holds NO key material (keys live in the 1Password SSH agent) but its
# topology - internal hosts, bastions, per-account aliases - is sensitive, so it
# lives in 1Password, not this repo. Reads the MACHINE service-account token
# directly (keychain on macOS, injected env on the remote box) rather than trusting
# the ambient env - so it never falls back to interactive auth on the wrong account,
# never uses a project-scoped token, and works even before .zshrc is applied. Safe
# to re-run: atomic write, 600 perms, never clobbers on failure.
# Provision ~/.ssh/config from a 1Password Secure Note (topology, no keys).
ssh-config:
    #!/usr/bin/env bash
    set -euo pipefail
    ref='op://OSX CLI/ssh-config/notesPlain'   # edit if your vault/item name differs
    command -v op >/dev/null 2>&1 || { echo 'op (1Password CLI) not found on PATH' >&2; exit 1; }
    # Always use the machine (OSX CLI) token: keychain on macOS, else injected env.
    tok="${OP_SERVICE_ACCOUNT_TOKEN:-}"
    if command -v security >/dev/null 2>&1; then
      k="$(security find-generic-password -s osx-cli-sa -a "$USER" -w 2>/dev/null || true)"
      [ -n "$k" ] && tok="$k"
    fi
    [ -n "$tok" ] || { echo 'no service-account token - seed the keychain (see .zshrc) or set OP_SERVICE_ACCOUNT_TOKEN' >&2; exit 1; }
    umask 077; mkdir -p "$HOME/.ssh"        # 700 dir, 600 file
    tmp="$(mktemp "$HOME/.ssh/.config.XXXXXX")"; trap 'rm -f "$tmp"' EXIT
    if ! OP_SERVICE_ACCOUNT_TOKEN="$tok" op read "$ref" > "$tmp"; then
      echo "could not read $ref - check the 'OSX CLI' service account has read on that" >&2
      echo "vault, and that the note/field names match (Secure Note body = notesPlain)." >&2
      exit 1
    fi
    [ -s "$tmp" ] || { echo "empty value from $ref - aborting so we don't clobber ~/.ssh/config" >&2; exit 1; }
    mv "$tmp" "$HOME/.ssh/config"; trap - EXIT
    echo "wrote ~/.ssh/config from $ref"

# Full machine update - nix flake update, darwin switch, brew/mas/mise, nvim/tmux
rebuild:
    #!/usr/bin/env bash
    # Source of truth; the `nix-rebuild` command on PATH shims here. flake.lock is
    # backed up before the bump and restored on failure, so a bad bump never lands.
    set -uo pipefail
    # Zap seatbelt (guard 1 of 2; the other is a preActivation check in the flake).
    # This machine uses the private wrapper (~/.nix-private -> /etc/nix-darwin, see
    # README "Private apps"). If the wrapper source exists but the symlink is gone,
    # rebuilding would fall back to the PUBLIC flake, which omits the private casks -
    # and cleanup="zap" would then DELETE their data (this is how we lost Plex/
    # SABnzbd/Calibre once). Abort instead. Don't auto-create: a scaffolded wrapper
    # has an EMPTY cask list, which re-arms the same footgun.
    if [ -e "$HOME/.nix-private/flake.nix" ] && [ ! -e /etc/nix-darwin/flake.nix ]; then
      echo 'error: ~/.nix-private exists but /etc/nix-darwin is missing/broken.' >&2
      echo 'Rebuilding now would drop your private casks and zap their data. Refusing.' >&2
      echo 'Fix: sudo ln -sfn "$HOME/.nix-private" /etc/nix-darwin   (or: just private-init)' >&2
      exit 1
    fi
    d="$HOME/.config/nix"
    restore() { mv "$d/.flake.lock.bak" "$d/flake.lock"
                [ -e /etc/nix-darwin/.flake.lock.bak ] && mv /etc/nix-darwin/.flake.lock.bak /etc/nix-darwin/flake.lock; }
    cp "$d/flake.lock" "$d/.flake.lock.bak" || exit 1
    echo '==> nix flake update' >&2
    if ! ( cd "$d" && nix flake update ); then restore; exit 1; fi
    # Private wrapper (README "Private apps"): when present, relock it so it
    # follows the repo's current state and switch from IT - pure eval, no
    # --impure, no sudo $HOME games. Without it (fresh machine, fork) the
    # public flake builds directly.
    flake="$d#default"
    if [ -e /etc/nix-darwin/flake.nix ]; then
      echo '==> relock private wrapper' >&2
      cp /etc/nix-darwin/flake.lock /etc/nix-darwin/.flake.lock.bak 2>/dev/null
      # --allow-dirty-locks: the repo lock was just bumped (uncommitted), so the
      # git+file input is "dirty" here by construction; nix refuses it otherwise.
      if ! ( cd /etc/nix-darwin && nix flake update --allow-dirty-locks ); then restore; exit 1; fi
      flake="/etc/nix-darwin#default"
    fi
    echo '==> darwin-rebuild switch' >&2
    if sudo "$(command -v darwin-rebuild)" switch --flake "$flake"; then
      rm -f "$d/.flake.lock.bak" /etc/nix-darwin/.flake.lock.bak
    else
      echo 'build failed - restored previous flake.lock; system unchanged' >&2
      restore; exit 1
    fi
    echo '==> brew upgrade' >&2; brew upgrade
    echo '==> mas upgrade'  >&2; mas upgrade
    echo '==> mise install (global defaults)' >&2; mise -C "$HOME" install
    echo '==> mise upgrade (global defaults)' >&2; mise -C "$HOME" upgrade
    if command -v nvim >/dev/null 2>&1; then echo '==> nvim +Lazy! sync' >&2; nvim --headless '+Lazy! sync' +qa; fi
    if tmux info >/dev/null 2>&1;       then echo '==> tmux reload' >&2;    tmux source-file "$HOME/.config/tmux/tmux.conf"; fi
