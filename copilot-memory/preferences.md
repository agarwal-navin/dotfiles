# Coding Preferences

> ⚠️ TOP PRIORITY — APPLY TO EVERY RESPONSE (has repeatedly not stuck):
> ALWAYS use "Claude Code Panel Style" — `##`/`###` headings, **bold** callouts,
> bullet/numbered lists. Put a `---` separator between agent PROCESS/THINKING narration
> and the USEFUL deliverable the user should actually read (see "Thinking vs. Deliverable
> Separation" below). Applies to short replies and mid-task status updates too.
> Before sending ANY response, verify it uses headings + structure, not a flat paragraph.

## Agent/Sub-agent Usage
- Primary: prioritize agents/sub-agents to complete tasks fast.
- Sticky default: use a sub-agent first for non-trivial requests; skip only when direct
  execution is clearly faster.
- Exception: for trivial tasks, use direct execution if faster than spawning a sub-agent.

## Workflow Approach
- Aim for end-to-end completion in one pass.
- Only ask questions when genuinely blocked.
- Execute directly rather than suggesting or asking permission.

## Git / PR Boundaries (IMPORTANT — do NOT auto-run without explicit request)
- User reviews changes LOCALLY before anything leaves the machine.
- Do NOT `git push` unless explicitly asked.
- Do NOT create/publish PRs unless explicitly asked. User marks PR draft/ready themselves.
- Do NOT add reviewers or enable auto-complete.
- Default: leave changes in working tree (or commit only if asked); stop before push/PR.
- "merge-readiness"/"finish the task" does NOT imply push or open PR — confirm first.

## Formatting Preference (Claude Code Panel Style)
- Use `##`/`###` heading sizes for visual hierarchy.
- Bold (`**text**`) for key points, important terms, callouts.
- Code blocks with language tags.
- Bullet/numbered lists for organized info.
- File links for repo references (no backticks per workspace conventions).
- Section headers: `## Thinking`, `## Actions`, `## Result`.
- Break up long responses with descriptive subheadings.
- Model after Claude Code panel: clear distinction between thinking, commands, deliverable.

## Thinking vs. Deliverable Separation (IMPORTANT — this is the whole point)
- The `---` separator exists to divide TWO things:
  1. ABOVE: agent PROCESS/THINKING narration — the interleaved chatter like
     "Now I'll fix all stale references...", "Change file staged, now commit...",
     "Let me check nothing references...". This is skimmable process, not the answer.
  2. BELOW: the USEFUL DELIVERABLE — the reader-facing answer/result the user should
     actually read (e.g. "All references are now consistent. Here's the audit result."
     plus the findings). This can be LONG and detailed — it IS the answer.
- Do NOT put a reductive "Summary" recap below the line. The below-the-line section is
  the substantive deliverable, not a shrunken restatement of what's above.
- Heading below the rule should name the actual deliverable (e.g. `## Result`,
  `## Audit Findings`, `## Answer`) — not a generic `## Summary`.
- Common mistake to avoid: burying the useful content above the line and dropping a
  redundant summary below. The useful content goes BELOW the separator.
