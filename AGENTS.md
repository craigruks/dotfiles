# Agent guide

High-signal gotchas for AI agents working in this repo - the things you'd
otherwise get wrong. Everything else (what the repo is, the stow/nix/brew
layers, secrets rationale) is in `README.md`. `CLAUDE.md` symlinks here.

## Use `just` - don't hand-roll commands

Run `just` to list tasks; reach for a recipe instead of reconstructing the
underlying command. `just test <tool>` verifies a change, `just apply` goes
live, `just rebuild` (or `nix-rebuild`) updates the machine. New repo tasks
become recipes in the `justfile`, not loose scripts.

## Stow trip-hazards

- Live files in `~/.config` and `~/.zshrc` are **symlinks into this repo** -
  editing them edits the repo. `~/.config` is one folded symlink to `.config/`.
- **Never `stow --restow` from a git worktree** - it repoints your live symlinks
  at an ephemeral checkout. Test a worktree's changes with `just test`, never by
  restowing; go live only from main via `just apply`.
- **New root-level files must be added to `.stow-local-ignore`**, or stow will
  symlink them into `$HOME`.

## Don't gitignore the lockfiles

`flake.lock` and `lazy-lock.json` are tracked on purpose (reproducibility).
Commit their bumps as diffs; never ignore them.

## Secrets

Never commit secrets - the gitleaks pre-commit hook blocks them and real secrets
live outside git. Full policy in `README.md`.

## Private apps live in `/etc/nix-darwin`, never in this repo

Machine-local casks/brews sit in a wrapper flake at `~/.nix-private`
(symlinked from `/etc/nix-darwin`) that composes this repo's
`darwinModules.default` - see README "Private apps". Don't add private app
names to `flake.nix`, and keep flake eval pure - no `builtins.getEnv`, no
`--impure` in recipes (impure reads get silently dropped by eval caching, and
`cleanup = "zap"` then uninstalls the apps they carried).

`cleanup = "zap"` is kept on purpose but guarded: `just rebuild` refuses if the
wrapper symlink is missing, and a `preActivation` check in `flake.nix` aborts
any activation that would zap a still-installed cask. Don't remove either guard
or switch to `uninstall` without saying so - they're what stops zap from
deleting Plex/SABnzbd/Calibre data (README "Private apps" → Zap seatbelt).

## Facts

User is `craigruks` - declared once in the `Fork here` block at the top of
`.config/nix/flake.nix` (`system.primaryUser` + the homebrew `user` both derive
from it); don't reintroduce the literal elsewhere. The darwin config is keyed
`default` (not by hostname), so every machine rebuilds `#default` - don't
reintroduce a hostname key or a `#mba13` in any command. Commits are small and
per-app with lowercase scopes (`tmux: …`, `nix: …`, `docs: …`); end the body
with the `Co-Authored-By:` trailer.
