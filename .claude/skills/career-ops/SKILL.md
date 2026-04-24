---
name: JobHuntAI
description: AI job search command center -- evaluate offers, generate CVs, scan portals, track applications
user_invocable: true
args: mode
argument-hint: "[scan | deep | pdf | oferta | ofertas | apply | batch | tracker | pipeline | contacto | training | project | interview-prep | update]"
---

# JobHuntAI -- Router

## Mode Routing

Determine the mode from `{{mode}}`:

| Input | Mode |
|-------|------|
| (empty / no args) | `discovery` -- Show command menu |
| JD text or URL (no sub-command) | **`auto-pipeline`** |
| `oferta` | `oferta` |
| `ofertas` | `ofertas` |
| `contacto` | `contacto` |
| `deep` | `deep` |
| `pdf` | `pdf` |
| `training` | `training` |
| `project` | `project` |
| `tracker` | `tracker` |
| `pipeline` | `pipeline` |
| `apply` | `apply` |
| `scan` | `scan` |
| `batch` | `batch` |
| `patterns` | `patterns` |

**Auto-pipeline detection:** If `{{mode}}` is not a known sub-command AND contains JD text (keywords: "responsibilities", "requirements", "qualifications", "about the role", "we're looking for", company name + role) or a URL to a JD, execute `auto-pipeline`.

If `{{mode}}` is not a sub-command AND doesn't look like a JD, show discovery.

---

## Discovery Mode (no arguments)

Show this menu:

```
JobHuntAI -- Command Center

Available commands:
  /JobHuntAI {JD}      → AUTO-PIPELINE: evaluate + report + PDF + tracker (paste text or URL)
  /JobHuntAI pipeline  → Process pending URLs from inbox (data/pipeline.md)
  /JobHuntAI oferta    → Evaluation only A-F (no auto PDF)
  /JobHuntAI ofertas   → Compare and rank multiple offers
  /JobHuntAI contacto  → LinkedIn power move: find contacts + draft message
  /JobHuntAI deep      → Deep research prompt about company
  /JobHuntAI pdf       → PDF only, ATS-optimized CV
  /JobHuntAI training  → Evaluate course/cert against North Star
  /JobHuntAI project   → Evaluate portfolio project idea
  /JobHuntAI tracker   → Application status overview
  /JobHuntAI apply     → Live application assistant (reads form + generates answers)
  /JobHuntAI scan      → Scan portals and discover new offers
  /JobHuntAI batch     → Batch processing with parallel workers
  /JobHuntAI patterns  → Analyze rejection patterns and improve targeting

Inbox: add URLs to data/pipeline.md → /JobHuntAI pipeline
Or paste a JD directly to run the full pipeline.
```

---

## Context Loading by Mode

After determining the mode, load the necessary files before executing:

### Modes that require `_shared.md` + their mode file:
Read `modes/_shared.md` + `modes/{mode}.md`

Applies to: `auto-pipeline`, `oferta`, `ofertas`, `pdf`, `contacto`, `apply`, `pipeline`, `scan`, `batch`

### Standalone modes (only their mode file):
Read `modes/{mode}.md`

Applies to: `tracker`, `deep`, `training`, `project`, `patterns`

### Modes delegated to subagent:
For `scan`, `apply` (with Playwright), and `pipeline` (3+ URLs): launch as Agent with the content of `_shared.md` + `modes/{mode}.md` injected into the subagent prompt.

```
Agent(
  subagent_type="general-purpose",
  prompt="[content of modes/_shared.md]\n\n[content of modes/{mode}.md]\n\n[invocation-specific data]",
  description="JobHuntAI {mode}"
)
```

Execute the instructions from the loaded mode file.
