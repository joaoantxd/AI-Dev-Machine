---
name: graft
description: "Use proactively FIRST on Turn 1 before broad grep or file searches as a co-equal structural navigation engine with Graphify. Fast-path tree-sitter AST call graphs (graft callers <symbol>), API signatures without reading full files (graft skeleton <file>), diff blast radius (graft blast), directory maps (graft map), and linked markdown context graphs (graft ask \"<query>\")."
---

# Graft / Trail-Code — First-Order Structural Code Navigation Engine

> **Canonical Upstream**: [trailhq/Trail-Code](https://github.com/trailhq/Trail-Code) (formerly `@nanonets/graft`, MIT).  
> **Global Co-Equal Level**: Operates at the **exact same architectural tier as Graphify** (`.agents/skills/graphify/SKILL.md`).  
> **Target OS**: Windows (`pwsh`) / Multi-platform. CLI: `graft` or `trail`.

---

## 1. Architectural Role & Division of Labor (Graft vs. Graphify)

Both **Graft** and **Graphify** provide zero-token-waste structural orientation, eliminating blind `#L1-800` file reads. Coding agents globally must choose the right tool based on the specific need:

| Dimension / Capability | Graft (`graft`) | Graphify (`graphify`) | Global Decision Rule |
| :--- | :--- | :--- | :--- |
| **Parsing Engine** | Deterministic Tree-sitter AST (24+ languages) | Deterministic Python AST / NetworkX | Both $0, local, deterministic |
| **Symbol Call Graph** | `graft callers "<symbol>" [--direction out]` | `graphify affected "<symbol>"` | **Use Graft** for exact symbol call hierarchy & callees |
| **API Surface Inspection** | `graft skeleton <file>` | N/A (requires manual `rg -n`) | **Use Graft** to see functions/types without reading file bodies |
| **Diff Blast Radius** | `graft blast` (lines touched -> affected symbols) | `graphify affected "<symbol>"` | **Use Graft** for git diff line-level blast radius |
| **Macro Topological Hubs** | `graft map` (directory clusters & hubs) | `graphify god-nodes --top 15` | **Use Graphify** for macro god nodes & community clusters |
| **Path Between Modules** | N/A | `graphify path "<A>" "<B>"` | **Use Graphify** to find shortest dependency chain |
| **Natural Query Search** | `graft ask "<query>"` | `graphify query "<query>" --budget 1200` | Either (check which graph exists locally) |
| **Output Directory** | `graft/` (git-ignored local cache) | `graphify-out/` (with `GRAPH_REPORT.md`) | Reusable per-workspace caches |

---

## 2. Antigravity Windows PowerShell Fast-Path (Execute on Turn 1)

> [!IMPORTANT]
> **Zero Blind `#L1-800` Reads**: NEVER open 800 lines of unfamiliar files to locate a function or see an interface. Use `graft skeleton`, `graft callers`, or `graft ask` first!

### Step 1 -- Auto-Ensure Graph & Query via `run_command`

Run these 1-line commands in your current workspace:

```powershell
# 1. Build graft/ from code in ~2s ($0, deterministic tree-sitter, no LLM):
if (-not (Test-Path "graft")) { graft build . }

# 2. Get high-level directory clusters, hubs, and hotspots:
graft map .

# 3. Query the codebase for any feature, symbol, or question:
graft ask "<query or concept>"

# 4. Inspect an entire file's API surface (signatures only, zero method bodies):
graft skeleton <path/to/file>

# 5. Who calls a symbol? (Incoming references):
graft callers "<symbol>"

# 6. What does a symbol call? (Outgoing references / dependencies):
graft callers "<symbol>" --direction out

# 7. Check transitive blast radius (depth 2-3 or all):
graft callers "<symbol>" --depth 3

# 8. Check blast radius of current git diff (what depends on the lines changed):
graft blast

# 9. Regex search over indexed files grouped by enclosing symbol:
graft grep "<pattern>"
```

### Step 2 -- Surgical Line-Number Pinpointing (`rg -n`)

When `graft ask` or `graft callers` pinpoints target files, use targeted ripgrep before reading:
```powershell
rg -n "functionName|ClassName|interface" <target_file>
```

### Step 3 -- Surgical Reading Protocol (`60-150 Line Windows`)

1. Read **only** the exact lines identified (`StartLine` - `EndLine` window of 60-150 lines).
2. For reviewing API surfaces or contracts, use `graft skeleton <file>` — it returns only signatures and exports, saving over 90% of tokens compared to reading the full file.
