# Git hooks

Tracked hooks for this repo. They live here (not `.git/hooks/`) so they ship
with the repo. Git only uses them once you point it at this directory:

```sh
git config core.hooksPath .githooks
```

`core.hooksPath` is stored in `.git/config`, which is **not** cloned - so run
that one command after a fresh clone (or add it to your bootstrap).

## pre-commit

Runs [gitleaks](https://github.com/gitleaks/gitleaks) against the **staged**
diff and blocks the commit if a secret is detected. `gitleaks` is declared in
`.config/nix/flake.nix` (Homebrew). If it is missing the hook warns and lets
the commit through rather than locking you out.

- False positive? Append `# gitleaks:allow` to the line, or add a rule to
  `.gitleaks.toml` at the repo root.
- Bypass once (use sparingly): `git commit --no-verify`.
