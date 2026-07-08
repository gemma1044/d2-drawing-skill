---
name: d2-diagram
description: Use a local D2 CLI to create and render .d2 diagrams. Use eagerly when the user mentions D2, .d2, d2.exe, architecture diagram, system diagram, flowchart, relationship graph, SVG/PNG rendering, text-to-diagram, or when Kroki/Mermaid failed and a local D2 renderer should be used.
---

# D2 Diagram Skill

Use this skill to create, edit, and render D2 diagrams with a local D2 CLI.

## When To Use

Use D2 when the user asks for:

- Architecture diagrams
- System relationship diagrams
- Flowcharts
- Module dependency diagrams
- Network / infrastructure diagrams
- Text-maintained diagrams stored in a repo
- SVG/PNG rendering from `.d2`

If the user explicitly says `D2`, `.d2`, `d2.exe`, or "use D2", do not switch to Kroki, Mermaid, or an online renderer unless the local D2 CLI is unavailable and the user approves another route.

## D2 CLI

Preferred executable resolution:

1. Environment variable `D2_BIN`
2. Windows default `D:\tools\d2\d2.exe`
3. `d2` from `PATH`

Check before rendering:

```powershell
if ($env:D2_BIN) { & $env:D2_BIN --version }
elseif (Test-Path "D:\tools\d2\d2.exe") { & "D:\tools\d2\d2.exe" --version }
else { d2 --version }
```

If D2 is missing, ask the user to install D2 or provide the `D2_BIN` path.

## Default Deliverables

Always keep the `.d2` source file.

For practical documentation and sharing, prefer PNG:

- Cursor preview: `.png`
- Markdown docs: `.png`
- Feishu/Lark, WeChat, Slack, Discord: `.png`
- High quality copy/paste: `@2x.png`

Keep `.svg` as an intermediate/vector source, not as the default user-facing deliverable, because many editors render or paste SVG poorly.

## Quick Workflow

1. Choose an output directory in the current project, usually `docs/`, `assets/`, `diagrams/`, or `public/`.
2. Write a short-kebab-case `.d2` file, for example `system-architecture.d2`.
3. Render `.d2` to `.svg` first.
4. If the user needs an image or copy-friendly output, convert SVG to `.png` and `@2x.png`.
5. Check the rendered diagram visually or at least inspect output dimensions.
6. Return paths for the source and rendered files.

Recommended render command:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/render-d2.ps1 -Source input.d2 -Output output.svg -Layout elk
```

Cross-project usage may require the absolute script path if the script is stored in a skill folder.

## PNG Rendering

D2 can output PNG directly, but on Windows it may trigger Playwright driver downloads. If network or DNS is blocked, that fails.

Use the stable two-step path:

1. Render D2 to SVG.
2. Convert SVG to PNG with PyMuPDF.

Check PyMuPDF:

```powershell
python -c "import fitz; print('pymupdf available')"
```

Convert:

```powershell
python scripts/svg-to-png-pymupdf.py output.svg
```

This creates:

- `output.png`
- `output@2x.png`

Prefer `@2x.png` when the user wants to paste the diagram into docs or chat apps.

Avoid CairoSVG as the default Windows path; it may install but fail at runtime because native Cairo DLLs are missing.

## Architecture Diagram Readability

Do not draw a large architecture diagram as one flat network. D2 layouts can become too wide or too tangled when many sibling nodes are placed at the same depth.

Rules:

1. Default to `direction: down` unless the user explicitly wants a horizontal pipeline.
2. For complex architecture diagrams, try `--layout elk`.
3. Target a readable width for laptop screens. If the SVG is very wide or very tall, revise the source rather than only changing themes.
4. Avoid putting more than about 5 sibling nodes in a single container.
5. Use layered containers, for example: entry layer -> runtime layer -> tool layer -> infrastructure layer -> result layer.
6. Keep node labels short: 1-3 lines, short phrases.
7. Keep only key cross-layer edges. Put detailed dependencies in a second diagram.
8. Use numbered main paths when useful.
9. After rendering, inspect readability. If lines cross heavily or text is tiny, rewrite the D2.

Suggested header:

```d2
direction: down
```

Suggested render for complex diagrams:

```powershell
D:\tools\d2\d2.exe --layout elk input.d2 output.svg
```

If ELK is worse, fall back to default layout and reduce sibling nodes, shorten labels, or split the diagram.

## Writing Guidelines

- Express structure first, then styling.
- Use containers to show ownership and boundaries.
- Use short edge labels to explain relationships.
- Use English IDs where possible; labels can be Chinese or English.
- For flowcharts, edge labels should be verbs such as `submit`, `validate`, `return result`.
- For architecture diagrams, separate:
  - product entry
  - runtime loop
  - tool system
  - infrastructure
  - external services
  - result/notification path

## Troubleshooting

- `d2 not found`: check `D2_BIN`, `D:\tools\d2\d2.exe`, or PATH.
- SVG not generated: check that the output parent directory exists.
- PNG generation fails with Playwright / driver download: render SVG first, then use PyMuPDF.
- Access denied: current project directory may be protected; choose a writable output folder.
- Diagram too wide or unreadable: use `direction: down`, reduce sibling nodes, split into multiple diagrams, or try `--layout elk`.
- Kroki/DNS errors: you are using the wrong renderer for a D2 task; use local D2 CLI.

## Minimal Example

```d2
direction: down

user: "User"
web: "Web App"
api: "API"
db: "PostgreSQL" {
  shape: cylinder
}

user -> web: "uses"
web -> api: "HTTPS"
api -> db: "read/write"
```
