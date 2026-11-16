# dotfiles

Personal GitHub Codespaces dotfiles seed **GitHub Copilot instructions and
Chat memory** into every codespace I create, so my coding preferences and repo-specific
notes follow me automatically — **without committing any of it into the target
repositories** (office-bohemia, FluidFramework, etc.).

When GitHub creates a new codespace, it clones this repo and runs [`install.sh`](install.sh),
which installs personal instructions and copies the Markdown files under
[`copilot-memory/`](copilot-memory) into Copilot Chat's memory storage.

## Repository contents

```text
.
├── install.sh                                  # bootstrap GitHub runs on every new codespace
├── README.md                                   # this file
├── copilot-instructions/
│   └── fluidframework-ado.instructions.md       # automatically applied personal instructions
└── copilot-memory/
    ├── preferences.md                          # USER-scope memory  -> applies to ALL codespaces
    └── repo/
        ├── office-bohemia/                     # REPO-scope memory -> only in office-bohemia codespaces
        │   └── ci-readiness-checklist.md
        └── FluidFramework/                    # REPO-scope memory -> only in FluidFramework codespaces
            ├── ado-auth.md
            └── documentation-style.md
```

| File | Memory scope | Seeded to | Applies in |
|------|--------------|-----------|-----------|
| [`copilot-memory/preferences.md`](copilot-memory/preferences.md) | User | `globalStorage/github.copilot-chat/memory-tool/memories/` | **Every** codespace |
| [`copilot-memory/repo/office-bohemia/*.md`](copilot-memory/repo/office-bohemia) | Repo | `workspaceStorage/<hash>/GitHub.copilot-chat/memory-tool/memories/repo/` | Only office-bohemia codespaces |
| [`copilot-memory/repo/FluidFramework/*.md`](copilot-memory/repo/FluidFramework) | Repo | `workspaceStorage/<hash>/GitHub.copilot-chat/memory-tool/memories/repo/` | Only FluidFramework codespaces |

## Automatically applied ADO instructions

The installer copies [`fluidframework-ado.instructions.md`](copilot-instructions/fluidframework-ado.instructions.md)
to `~/.copilot/instructions/` and the existing authentication guide to
`~/.copilot/reference/FluidFramework/ado-auth.md`.
It uses `$COPILOT_HOME` instead of `~/.copilot` when that variable is set.
These dedicated files are updated on each install without replacing other personal instructions.

The instructions ask agents working in FluidFramework to read the guide before their first response.
They also include the essential `azureauth` command directly, so an agent does not have to discover the guide to know the initial authentication method.
Tokens are obtained only when needed, not during installation.
Nothing is written into the FluidFramework checkout.

Copilot CLI and the VS Code Copilot harness support this personal instruction location.
Other harnesses have different discovery rules; the VS Code Local harness, for example, uses profile instructions.
See the [VS Code user-instruction reference](https://code.visualstudio.com/docs/agents/reference/custom-instructions-reference#_user-instructions).
The instruction file is available across projects but explicitly limits its guidance to FluidFramework.

After installation, run `copilot instruction list` from FluidFramework to check CLI discovery.
In VS Code, use **Chat: Open Customizations** and inspect **Instructions** with the Copilot harness selected.
Start a new chat and verify that the agent reads the guide before responding.
Discovery and instructions guide agent behavior; they do not guarantee compliance.

## What preferences it sets

### User scope — [`preferences.md`](copilot-memory/preferences.md) (loaded in every codespace)

- **Response formatting ("Claude Code Panel Style")** — the top-priority rule. Every
  reply uses hierarchical `##`/`###` headings, **bold** callouts, and bullet/numbered
  lists instead of flat paragraphs.
- **Thinking vs. Deliverable separation** — a `---` separator divides skimmable
  agent *process/thinking* narration (above) from the *useful, reader-facing
  deliverable* (below). The part below the line is the substantive answer, **not** a
  reductive summary.
- **Agent / sub-agent usage** — prefer agents/sub-agents to move fast on non-trivial
  work; use direct execution only when it's clearly faster.
- **Workflow approach** — aim for end-to-end completion in one pass; only ask when
  genuinely blocked; execute rather than asking permission.
- **Git / PR boundaries** — never `git push`, open/publish PRs, add reviewers, or
  enable auto-complete unless explicitly asked. Default is to leave changes in the
  working tree for local review.

### Repo scope — office-bohemia only

- [`ci-readiness-checklist.md`](copilot-memory/repo/office-bohemia/ci-readiness-checklist.md)
  — a trigger reminding the agent to verify against the CI readiness checklist
  (`docs/developer-guide/testing/what-to-test/index.md`) before PR creation, branch
  push, or a Dogfood/Public Preview release.

### Repo scope — FluidFramework only

- [`documentation-style.md`](copilot-memory/repo/FluidFramework/documentation-style.md)
  — use Simplified Technical English for source-code comments.
  Keep comments and documentation connected, with enough context to explain how ideas relate and why they matter.

## How it hooks in

Dotfiles are an **account-level** GitHub feature, not per-repo:

1. Push this folder to a repo on your account (name it `dotfiles` for auto-detection).
2. GitHub → **Settings → Codespaces → "Automatically install dotfiles"** → enable and
   select this repo.
3. On **every** new codespace you create, GitHub clones this repo to
   `/workspaces/.codespaces/.persistedshare/dotfiles` and runs [`install.sh`](install.sh)
   inside the container.

The target repos never reference this — GitHub injects it universally.

## How `install.sh` works

Before seeding memory, the script installs the personal instruction file and its authentication guide.
This does not depend on VS Code creating `workspaceStorage`.

1. **User preferences** → always copied into Copilot's **global storage** memory dir.
   Works at bootstrap in every codespace.
2. **Repo notes** → copied into the codespace's **workspaceStorage** memory dir, but
   only when the codespace actually is that repo (detected via the
   `/workspaces/<repo>` checkout or `$GITHUB_REPOSITORY`). This keeps office-bohemia's
   CI notes out of FluidFramework and other codespaces.

The script is **idempotent** — safe to run repeatedly; it overwrites the seeded files
with the versions in this repo (this repo is the source of truth).

## Verify it worked (in a new codespace)

```bash
# 1) Did GitHub auto-run the dotfiles?
ls /workspaces/.codespaces/.persistedshare/dotfiles && echo "dotfiles auto-installed"

# 2) User preferences seeded?
head -8 ~/.vscode-remote/data/User/globalStorage/github.copilot-chat/memory-tool/memories/preferences.md

# 3) Repo notes seeded (office-bohemia codespace)?
ls ~/.vscode-remote/data/User/workspaceStorage/*/GitHub.copilot-chat/memory-tool/memories/repo/
```

Then ask Copilot a throwaway question and confirm it replies in the Claude-panel
format — that proves the memory is being **loaded**, not just present on disk.

## Notes / limitations

- On a brand-new codespace, `workspaceStorage` may not exist yet when dotfiles run,
  so the repo-scope notes are best-effort. If you see the "re-run" hint, just run:

  ```bash
  bash ~/dotfiles/install.sh
  ```

- The script is **idempotent** — safe to run repeatedly. It overwrites the seeded
  files with the versions in this repo (this repo is the source of truth).
- Storage-path casing differs by design and the script handles both:
  `globalStorage/github.copilot-chat` (lower) vs
  `workspaceStorage/<hash>/GitHub.copilot-chat` (mixed).

## Editing preferences

Edit the Markdown under [`copilot-memory/`](copilot-memory), commit, and push. New
codespaces pick up the changes on creation; existing ones update on the next
`bash ~/dotfiles/install.sh`.

## Add another repo's notes

1. Create `copilot-memory/repo/<repo-name>/<note>.md`.
2. Add a `seed_repo "<repo-name>"` line near the bottom of [`install.sh`](install.sh).
