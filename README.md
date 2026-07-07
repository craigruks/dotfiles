# dotfiles

Personal macOS dotfiles, managed declaratively. Cloned to `~/.dotfiles` and
symlinked into `$HOME` with GNU Stow; system + packages are reproduced with
nix-darwin and Homebrew.

> [!TIP]
> **New machine?** → [First-time setup](#first-time-setup-new-machine) ·
> **Daily driving?** → [Daily usage](#daily-usage) ·
> **Forking?** → [Forking this](#forking-this)

> [!IMPORTANT]
> **Reading this as an automated agent?** Start with [`AGENTS.md`](AGENTS.md)
> (the short version: use `just` for every task), then the
> [Secrets policy](#secrets-policy-read-this) and
> [Conventions & gotchas](#conventions--gotchas) before committing anything.

## Ethos

Six things I weigh every change against:

- **Speed.** The shell should feel instant. Plugins load deferred (zinit `wait
  lucid`), completions are cached (`compinit -C`), and the prompt is
  [starship](https://starship.rs/) (compiled Rust, not a shell script). If
  something adds startup lag for little gain, it goes.
- **Only what I actually use.** Every package, `.config` dir, and plugin has to
  earn its spot. Unused stuff gets removed, not kept "just in case" (fish, atuin,
  act, and gitmux all went once they stopped pulling weight). The flake and
  `.config` stay easy to audit because they only hold things I'm running.
- **One job per tool.** No two tools do the same thing, and nothing shows up
  twice. starship owns the prompt (cwd, git, languages), the tmux bar owns the
  session (which one, how long it's up), [sesh](https://github.com/joshmedeski/sesh)
  owns sessions, [mise](https://mise.jdx.dev/) owns per-project runtimes, `just`
  owns repo tasks, nix owns the system, Stow owns symlinks. When two overlap, one
  goes. That's why gitmux left the tmux bar: starship already shows git.
- **Nothing goes stale.** Pruning is a real task, not someday-cleanup. Retirement
  notes carry dates, dead casks and configs get pulled the moment they stop
  working, and `nix-rebuild` pulls fresh upstream every run (with the lock bump
  shown as a diff so a bad one never lands silently).
- **Reversible by default.** Nothing should risk the live machine. `just test`
  boots a tool in a throwaway env, `just rollback` steps back a generation, and
  `nix-rebuild` restores `flake.lock` if a build fails. So experiments can't
  break the running system.
- **Comment the why, not the what.** When a choice isn't obvious (why `mas` is
  off, why a cask stays manual, why gitmux got dropped), the reason lives right
  next to it. Saves future me, and stops an agent from "fixing" something that
  was deliberate.

## How it works (three layers)

| Layer | What it does | Where |
|-------|--------------|-------|
| **GNU Stow** | Symlinks dotfiles from this repo into `$HOME` (e.g. `~/.zshrc` links to `.dotfiles/.zshrc`) | repo root, `.stow-local-ignore` |
| **nix-darwin** | Declarative system config, CLI packages, fonts. Config keyed `default`; `username` set at the top of the flake. | `.config/nix/flake.nix` |
| **Homebrew** (via `nix-homebrew`) | GUI casks + brews that aren't in nixpkgs, with declarative taps | `homebrew {}` block in `flake.nix` |

Nix is the **Determinate Systems** distribution; its daemon is a launchd
background item (see gotchas below).

## Layout

```
~/.dotfiles
├── justfile               # ALL repo tasks, run `just` to list (test/apply/rebuild/…)
├── AGENTS.md              # agent guide (CLAUDE.md is a symlink to it)
├── .zshrc                 # shell: nix PATH, history rescue, aliases
├── .local/bin/            # personal scripts on PATH (nix-rebuild shims `just rebuild`)
├── .config/               # XDG configs (stowed into ~/.config)
│   ├── nix/flake.nix      # nix-darwin system definition (username var at top; keyed #default)
│   ├── ghostty/ mise/ gh/ zed/ tmux/ ...
│   └── nvim/              # LazyVim config (tracked directly)
├── .githooks/             # tracked git hooks (gitleaks pre-commit)
├── .gitleaks.toml         # secret-scanner config + false-positive allowlist
├── .gitignore             # tracked (rules ship with the repo)
└── .stow-local-ignore     # files Stow must NOT symlink into $HOME
```

## First-time setup (new machine)

Steps 1 to 3 and 5 need a human (interactive installer, `sudo`, pasting the
1Password token, enabling the SSH agent); step 4 an agent can drive, since the
heavy lifting is one idempotent `just setup`.

```sh
# 1. Install Determinate Nix  [human]
#    https://docs.determinate.systems/   (curl -fsSL https://install.determinate.systems/nix | sh -s -- install)

# 2. Clone into $HOME  (forking? point this at your own fork)
git clone git@github.com:craigruks/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# 3. Build the system. First run bootstraps nix-darwin and installs just,
#    stow, gitleaks, etc.  [human: sudo]
#    (forking? set `username` at the top of flake.nix first)
sudo darwin-rebuild switch --flake ~/.config/nix#default

# 4. Open a NEW shell so nix's PATH (and `just`) are active, then finish setup.
#    `just setup` = stow symlinks + arm gitleaks hook + bootstrap tpm (idempotent).
just setup
#    then: open tmux and press <prefix> + I to install plugins; run :Lazy sync in nvim.

# 5. Secrets & SSH  [human]. How it works: see "Secrets policy" below.
#    a) Seed the osx-cli-sa 1Password service-account token into the keychain:
#         security add-generic-password -s osx-cli-sa -a "$USER" -w   # paste the token
#    b) Provision ~/.ssh/config from 1Password (uses the token from a):
#         just ssh-config
#    c) In the 1Password app: turn on the SSH agent and sign in (it serves your
#       private keys). Save each key's public stub at ~/.ssh/<name>.pub (the
#       config selects keys by these). git-over-SSH then works: agent (keys) +
#       config from (b) + the ~/.ssh/*.pub selectors. See "Secrets policy".

# 6. (optional) Private apps kept out of this repo - see "Private apps" below.
just private-init
```

### Forking this

These are personal dotfiles, but forking is two edits:

- **`flake.nix`**: set `username` in the `Fork here` block at the top. It owns
  the homebrew prefix and is `system.primaryUser`; both downstream uses derive
  from that one var. It has to be declared in git, since pure flake eval can't
  read `$USER`, run `whoami`, or read an untracked local file, so there's no way
  to auto-detect it (that's the same reason the config is keyed `default` instead
  of by hostname: nothing per-machine to sync, every host rebuilds `#default`).
- **`git clone` URL**: point step 2 above at your own fork.

Everything else (shell, editor, tmux, ghostty, git, …) is portable.

## Private apps (the `/etc/nix-darwin` wrapper)

Casks/brews I keep out of the public repo live in a **machine-local wrapper
flake** at `~/.nix-private`, symlinked from `/etc/nix-darwin` (nix-darwin's
default flake location). It takes this repo's flake as an input and appends
its private lists to the exported `darwinModules.default` (list options
merge). `just private-init` scaffolds it; add apps, then `just rebuild`, which
relocks the wrapper every run so it follows the repo (`--allow-dirty-locks`,
since the repo lock is freshly bumped at that moment). Without the wrapper the
public flake builds directly - forks and fresh machines need none of this, and
`sudo rm /etc/nix-darwin` opts back out.

Why a wrapper instead of a gitignored file read impurely: eval stays pure, so
user, root, and a fresh clone all build the same system and nothing private is
silently dropped - which matters with `cleanup = "zap"`, where a dropped cask
is an *uninstalled* app. And since the `git+file` input sees only tracked
files, private names structurally can't touch git.

**Zap seatbelt.** `cleanup = "zap"` deletes a removed cask's *data* (its
`~/Library/Application Support/…`, prefs) via the cask's zap stanza, not just
the app. So if a rebuild ever drops a still-installed cask - broken wrapper,
commented-out line, typo - it would erase that data (this cost us Plex,
SABnzbd, and Calibre once). Two guards prevent it: `just rebuild` aborts if
`~/.nix-private` exists but `/etc/nix-darwin` is gone, and a `preActivation`
check in the flake aborts *any* activation (even a raw `darwin-rebuild switch`)
when the build no longer declares a cask that's currently installed. To retire
a cask on purpose: `brew uninstall --zap <name>` by hand, then drop it from the
config. Both guards arm only while `cleanup = "zap"`.

## Daily usage

- **Repo tasks go through `just`.** Run `just` (no args) to list them. Recipes
  self-locate to the checkout you're in, so `just test …` inside a git worktree
  tests that branch. Key ones: `just test <tool>` (isolated test), `just apply`
  (go live), `just rollback <ref>`, `just sync`, `just rebuild`.
- **Update everything:** `nix-rebuild` (from any cwd) or `just rebuild` (in the
  repo), same code. Runs `nix flake update` → relock the private wrapper if
  `/etc/nix-darwin` exists (see "Private apps") → `darwin-rebuild switch` →
  `brew upgrade` → `mas upgrade` → `mise` → `nvim +Lazy! sync` → tmux reload, in
  your login session (so `mas` works). It backs up the lockfiles first and
  **restores them if the build fails**, so a bad upstream bump never lands.
- **Rebuild without bumping pins:** `sudo darwin-rebuild switch` (bare - it
  defaults to `/etc/nix-darwin`, your wrapper, so private casks stay declared).
  On a machine without the wrapper, `sudo darwin-rebuild switch --flake ~/.config/nix#default`.
  Avoid `--flake ~/.config/nix#default` when the wrapper exists: it drops the
  private casks, which under `cleanup = "zap"` would zap their data (the
  seatbelt below now blocks this, but don't rely on it).
- **Test a change safely:** `just test <tmux|nvim|zsh|ghostty|nix>` boots the
  tool against the current checkout in a throwaway env, never touching live config.
- **Add a package:**
  - CLI tool in nixpkgs → `environment.systemPackages` in `flake.nix`.
  - GUI app → `homebrew.casks`. Formula from a tap → declare the tap in
    `homebrew.taps` and reference it as `owner/tap/name`.
- **Review changes before committing** with [`hunk`](https://github.com/modem-dev/hunk):
  `hunk diff` (working tree) or `hunk show <ref>` (a commit).
- **Commit style:** small, per-app commits (e.g. `ghostty: …`, `nix: …`).

## Secrets policy (READ THIS)

> [!IMPORTANT]
> **Two rules:** no secret value ever lands in git or in a plaintext file, and
> anything sensitive lives in **1Password**. Config files hold only `op://`
> *references*, never values. The value is resolved at runtime and, crucially,
> **siloed**: a process is handed exactly the secret it names, never a whole vault.

### Who owns what

1Password is the single source of truth. Two tools read from it, in
non-overlapping scopes (this is deliberate, "one job per tool"):

| Tool | Scope | Why it, not the other |
|------|-------|-----------------------|
| **[fnox](https://github.com/jdx/fnox)** | Machine / **ambient** secrets: login-shell env vars, resolved once and cached by its per-user daemon. Config: `.config/fnox/config.toml` (global) + a per-project `fnox.toml`. | Only fnox has a global config, a shell-activation hook, and a caching daemon; varlock is project-scoped and can't provide ambient env. |
| **[varlock](https://github.com/dmno-dev/varlock)** | **Per-project** env: `.env.schema` validation, type coercion, `typegen`, and runtime redaction of secret values in app output. | fnox has no schema/validation/typegen/log-redaction. varlock stays the schema layer; fnox resolves/caches in front of it. |

Supporting layers: **SSH keys** are served by the **1Password SSH agent**
(`SSH_AUTH_SOCK`, `.zshrc`); the **service-account token** ("secret zero") lives
in the **macOS login keychain**; **gitleaks** is the commit-time backstop.
`~/.ssh/config` itself (sensitive topology: internal hosts, bastions,
per-account aliases, but no key material) is a **1Password Secure Note**,
provisioned headlessly with `just ssh-config`. It's a real file, not stowed and
not in this repo.

**How git-over-SSH resolves** (the three pieces must all be present): a remote
uses a host alias (`git@gh-work:org/repo.git`); the config's
`IdentityFile ~/.ssh/<key>.pub` + `IdentitiesOnly yes` picks *which* key for that
host; and the **1Password agent serves the matching private key** (biometric), so
the private key never lands on disk. `just ssh-config` supplies the config;
the agent supplies the keys; the `.pub` stubs (Time-Machine-restored) are the
selectors. With multiple GitHub accounts, `IdentitiesOnly yes` is what stops ssh
from offering the wrong key first.

**Adding a key** (the storage workflow): create or import the SSH key in
1Password so the agent serves it; save its public half at `~/.ssh/<name>.pub`
(the selector, not a secret); then add a Host alias to `~/.ssh/config` (which
lives in the `ssh-config` Secure Note and is applied by `just ssh-config`). Use
one custom alias per account, each pointing `IdentityFile` at its stub:

```sshconfig
Host gh-personal                 # remote: git@gh-personal:you/repo.git
  HostName github.com
  User git
  IdentityFile ~/.ssh/personal.pub
  IdentitiesOnly yes

Host gh-work
  HostName github.com
  User git
  IdentityFile ~/.ssh/work.pub
  IdentitiesOnly yes
```

### Layers of defense, in order

<details>
<summary>The five layers, from source of truth to commit-time backstop</summary>

1. **No values in git.** Secrets live in 1Password; configs reference
   `op://vault/item/field`. fnox/varlock resolve them at runtime via a 1Password
   **service account**, so it works headlessly (the remote box has no GUI). A
   gitignored `.env` (`.env`, `.env.*`, `*.env`; `.env.example` / `.env.schema`
   stay committable) remains the low-tech fallback.
2. **Siloing / least privilege.** Machine secrets go in a dedicated `OSX CLI` vault;
   the service account is granted **read on only that vault**, so it can never
   see personal logins. Each `op://` reference fetches **one field**, never a
   vault dump, and never "ask for the whole vault at once."
3. **Secret zero lives in the keychain.** `OP_SERVICE_ACCOUNT_TOKEN` is the one
   credential that can't come from 1Password (chicken-and-egg), so it sits in the
   macOS login keychain and `.zshrc` exports it into every shell. Seed it once on
   a new machine: `security add-generic-password -s osx-cli-sa -a "$USER" -w`.
   On the remote box (no keychain) it's injected as an env var by the host.
4. **Pre-commit hook** (`.githooks/pre-commit`) runs `gitleaks` on staged changes
   and blocks the commit if it finds a secret. Requires
   `git config core.hooksPath .githooks` once per clone (armed by `just setup`,
   step 4 above). Bypass only for a known false positive: `# gitleaks:allow` on
   the line, an allowlist entry in `.gitleaks.toml`, or `git commit --no-verify`
   (last resort).
5. **Credential-bearing app dirs are gitignored** and never enter git even though
   they live on disk: `gcloud/`, `op/`, `neonctl/`, `audio-metadata-scanner/`,
   `aws`, `tokscale/`, `raycast/` (plus a few app-specific state dirs). `.gitignore`
   is **tracked** (via `!/.gitignore`) so the rules ship to every clone;
   `.gitleaks.toml` allowlists confirmed false positives (minified Raycast bundles
   trip the linear/asana rules).

</details>

> [!WARNING]
> If a secret ever lands in history: **rotate it first** (scrubbing ≠ un-leaking),
> then rewrite with `git filter-repo` *before* pushing.

## Conventions & gotchas

> [!WARNING]
> Never `stow --restow` from a git worktree - it repoints your live symlinks at
> an ephemeral checkout. Test worktree changes with `just test`; go live only
> from main via `just apply`.

> [!WARNING]
> The Nix daemon is a Determinate launchd background item. Disabling it in
> *System Settings → General → Login Items & Extensions → Allow in the
> Background* makes every `nix` command fail with `Connection refused`.
> Re-enable it there, or `sudo determinate-nixd init`.

- **`flake.lock` is committed.** It pins exact input revisions for reproducible
  builds. Never ignore it. `nix-rebuild` shows lock bumps as reviewable diffs.
- **Nested `.gitignore` files are ignored** (`**/.gitignore`); only the root one
  is tracked. New repo-infra files at the root must be added to
  `.stow-local-ignore` so Stow doesn't symlink them into `$HOME`.
- `gitleaks` and `git-filter-repo` are declared in the flake / installed via brew.

## Credits

Standing on the shoulders of these projects and their authors:

**tmux & sessions**
- [tpm](https://github.com/tmux-plugins/tpm) by tmux-plugins
- [sesh](https://github.com/joshmedeski/sesh) & [tmux-nerd-font-window-name](https://github.com/joshmedeski/tmux-nerd-font-window-name) by Josh Medeski
- [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) by Chris Toomey

**Editor & shell**
- [LazyVim](https://github.com/LazyVim/LazyVim) & [lazy.nvim](https://github.com/folke/lazy.nvim) by Folke Lemaitre
- [starship](https://starship.rs/) prompt, [mise](https://mise.jdx.dev/), [zinit](https://github.com/zdharma-continuum/zinit)

**System & tooling**
- [Determinate Nix](https://determinate.systems/), the nix-darwin distribution
- [gitleaks](https://github.com/gitleaks/gitleaks), secret scanning
- [hunk](https://github.com/modem-dev/hunk), a review-first diff viewer
- [fnox](https://github.com/jdx/fnox), machine/ambient secret resolver (1Password)
- [varlock](https://github.com/dmno-dev/varlock), per-project env schema + validation

## Research

- [Stow](https://www.youtube.com/watch?v=y6XCebnB9gs)
- [Zsh](https://www.youtube.com/watch?v=ud7YxC33Z3w)
- [Nix](https://www.youtube.com/watch?v=Z8BL8mdzWHI)
- [Nix packages](https://search.nixos.org/packages)
