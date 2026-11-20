# Installing Dolphin

## The one line (recommended)

```bash
npx skills add knsiuss/dolphin
```

That is the whole install for the skill layer. The `skills` CLI
(Vercel Labs) clones this repo, puts one canonical copy of each
skill in `.agents/skills/`, and links it into every harness you
pick — Claude Code, OpenCode, Codex, Cursor, and 75+ others.
Useful flags:

```bash
npx skills add knsiuss/dolphin -a claude-code opencode -y   # pick harnesses, no prompts
npx skills add knsiuss/dolphin -g                           # global: every project
npx skills add knsiuss/dolphin@dolphin-protocol             # a single skill
```

Two more pieces, both small:

- **Agent definitions.** Delegates run as the definitions in
  `agents/` (`dolphin-agent`, `dolphin-auditor`). Claude Code
  reads them from `.claude/agents/` (project) or
  `~/.claude/agents/` (global) — copy them there. Other harnesses
  have their own subagent format; the two files are plain markdown
  with minimal frontmatter and adapt directly.
- **Per-project state.** Once per project, run
  `dolphin-init.sh` from the installed `dolphin-protocol` skill's
  `scripts/` folder. It scaffolds `.dolphin/` (scopes, evidence,
  memory, calibration, outcomes) and copies the deterministic
  tools (`dolphin-scan`, `dolphin-metrics`) into `.dolphin/bin/` —
  the stable path the skills mean afterwards, independent of
  harness or install location.

Then type `/dolphin <task>` in the main session. That is the
whole runtime: there is no pod to start and nothing to keep alive.

## Manual install (no npx)

From the unpacked pack, inside your project:

```bash
scripts/dolphin-install.sh claude .     # or: opencode | codex | cursor | agents
```

This copies all 13 skill folders into the directory your harness
scans, and — for `claude` — the agent definitions into
`.claude/agents/`:

| Harness | Project skills dir | Global skills dir |
|---|---|---|
| Claude Code | `.claude/skills/` | `~/.claude/skills/` |
| OpenCode | `.opencode/skills/` | `~/.config/opencode/skills/` |
| Codex CLI | `.agents/skills/` | `~/.agents/skills/` |
| Cursor | `.cursor/skills/` | `~/.cursor/skills/` |
| Neutral (multi-harness repo) | `.agents/skills/` | `~/.agents/skills/` |

Worth knowing:

- **OpenCode reads three roots**: its own `.opencode/skills/`, plus
  `.claude/skills/` and `.agents/skills/` (project and global). An
  install made for Claude Code — or by the skills CLI — is already
  visible to OpenCode with zero extra work.
- Claude-specific frontmatter in the skills (e.g.
  `disable-model-invocation`) is ignored by the other harnesses,
  not an error.
- In OpenCode, a skill only exists for the model if its
  `description` is present — all Dolphin skills ship one.

## Harnesses without subagents (degraded mode)

If the harness cannot spawn subagents, `/dolphin` still works:
the leader runs the roles sequentially in the main session,
wearing one hat at a time and saying which. You lose parallelism
and judge independence weakens (the leader marks the lenses as
self-review in its report) — the scope gate, the file discipline,
and the evidence rules are unchanged. Harnesses without a skills
system at all (Gemini CLI, Aider, Copilot CLI): paste
`skills/dolphin-protocol/SKILL.md` plus the needed role skills
into the harness's instruction file (`AGENTS.md` / `GEMINI.md` /
system prompt).

## Verify

```bash
bash tests/smoke.sh   # structure, agent defs, init, deterministic scans
```

## Publishing (maintainers)

The repo **is** the pack: `skills/` at the root is what the skills
CLI scans. Push this folder to GitHub as `knsiuss/dolphin` and
the one line above works for everyone:

```bash
git init && git add -A && git commit -m "Dolphin"
gh repo create knsiuss/dolphin --public --source=. --push
```
