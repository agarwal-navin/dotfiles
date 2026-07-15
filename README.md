# dotfiles

Personal GitHub Codespaces dotfiles. Currently seeds **GitHub Copilot Chat memory**
so my coding preferences follow me into every codespace — without committing anything
into the target repositories (office-bohemia, FluidFramework, etc.).

## How it hooks in

Dotfiles are an **account-level** GitHub feature, not per-repo:

1. Push this folder to a repo on your account (name it `dotfiles` for auto-detection).
2. GitHub → **Settings → Codespaces → "Automatically install dotfiles"** → enable and
   select this repo.
3. On **every** new codespace you create, GitHub clones this repo and runs
   [`install.sh`](install.sh) inside the container.

The repos themselves never reference this — GitHub injects it universally.

## What it does

- **User scope** ([copilot-memory/preferences.md](copilot-memory/preferences.md)) →
  written to Copilot's **global storage**. Applies to **all** codespaces.
- **Repo scope** ([copilot-memory/repo/office-bohemia/](copilot-memory/repo/office-bohemia))
  → written to the codespace's **workspaceStorage**, but only when this codespace
  actually is office-bohemia (detected via the `/workspaces/office-bohemia` checkout
  or `$GITHUB_REPOSITORY`). Kept out of FluidFramework and other repos.

## Notes / limitations

- On a brand-new codespace, `workspaceStorage` may not exist yet when dotfiles run,
  so the repo-scope notes are best-effort. If you see the "re-run" hint, just run:

  ```bash
  bash ~/dotfiles/install.sh
  ```

- The script is **idempotent** — safe to run repeatedly. It overwrites the seeded
  files with the versions in this repo (this repo is the source of truth).
- Storage-path casing differs by design: `globalStorage/github.copilot-chat` (lower)
  vs `workspaceStorage/<hash>/GitHub.copilot-chat` (mixed). The script handles both.

## Add another repo's notes

1. Create `copilot-memory/repo/<repo-name>/<note>.md`.
2. Add a `seed_repo "<repo-name>"` line near the bottom of [`install.sh`](install.sh).
