# Installing Dolphin

## The one line (recommended)

```bash
npx skills add knsiuss/dolphin
```

That is the whole install for the skill layer. The `skills` CLI
(Vercel Labs) clones this repo, puts one canonical copy of each skill
in `.agents/skills/`, and links it into every harness you pick —
Claude Code, OpenCode, Codex, Cursor, and 75+ others. Useful flags:

```bash
npx skills add knsiuss/dolphin -a claude-code opencode -y   # pick harnesses, no prompts
npx skills add knsiuss/dolphin -g                           # global: every project
npx skills add knsiuss/dolphin@dolphin-protocol             # a single skill
```

Then, per project, initialise the board (step 2 of the README quick
start). The pod's scripts — board, claim leases, secretary, scanner,
launcher — ship **inside the `dolphin-protocol` skill's `scripts/`
folder**, so they arrive with the skills; `dolphin-init.sh` copies
them into the project's `.dolphin/bin/`, which is the stable path
every session uses afterwards, independent of harness or install
location.

## Dolphin's own CLI

```bash
npx dolphin-pod install claude .    # claude | opencode | codex | cursor | agents
npx dolphin-pod init                # create .dolphin/ in this project
npx dolphin-pod help                # all commands
```

On Windows, run it inside WSL (the scripts are bash, the launcher uses tmux).

## Manual install (no npx)

From the unpacked pack, inside your project:

```bash
scripts/dolphin-install.sh opencode .     # or: claude | codex | cursor | agents
```

This copies the 12 `dolphin-*` skill folders into the directory your
harness scans:

| Harness | Project skills dir | Global skills dir | `DOLPHIN_CMD` |
|---|---|---|---|
| Claude Code | `.claude/skills/` | `~/.claude/skills/` | `claude` |
| OpenCode | `.opencode/skills/` | `~/.config/opencode/skills/` | `opencode` |
| Codex CLI | `.agents/skills/` | `~/.agents/skills/` | `codex` |
| Cursor | `.cursor/skills/` | `~/.cursor/skills/` | `cursor-agent` |
| Neutral (multi-harness repo) | `.agents/skills/` | `~/.agents/skills/` | your CLI |

Worth knowing:

- **OpenCode reads three roots**: its own `.opencode/skills/`, plus
  `.claude/skills/` and `.agents/skills/` (project and global). An
  install made for Claude Code — or by the skills CLI — is already
  visible to OpenCode with zero extra work.
- Claude-specific frontmatter in the skills (e.g.
  `disable-model-invocation`) is ignored by the other harnesses, not
  an error.
- In OpenCode, a skill only exists for the model if its `description`
  is present — all Dolphin skills ship one.

## Harnesses without a skills system (degraded mode)

Gemini CLI, Aider, Copilot CLI and similar: the board and scripts work
unchanged (claims, secretary, scanner, launcher via `DOLPHIN_CMD`).
For the skill layer, paste `skills/dolphin-protocol/SKILL.md` plus the
session's role skill into the harness's instruction file
(`AGENTS.md` / `GEMINI.md` / system prompt). You lose on-demand skill
loading, not coordination.

## Verify

```bash
bash tests/smoke.sh   # board, claims, scanner, launcher, secretary poke
```

## Publishing (maintainers)

The repo **is** the pack: `skills/` at the root is what the skills CLI
scans. Push this folder to GitHub as `knsiuss/dolphin` and the one
line above works for everyone:

```bash
git init && git add -A && git commit -m "Dolphin"
gh repo create knsiuss/dolphin --public --source=. --push
```

To also publish the CLI to npm (check the name is free with
`npm view dolphin-pod`, or switch to a scoped name):

```bash
npm login
npm pack --dry-run      # inspect the tarball
npm publish
```

`.gitattributes` forces LF line endings. Keep it: CRLF in the bash
scripts breaks them on WSL, Linux and macOS.
